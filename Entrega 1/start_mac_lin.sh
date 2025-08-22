#!/bin/bash

# Script para inicializar o projeto F1 Miniatures
# Funciona no Linux e macOS

set -e  # Parar em caso de erro

echo "🏎️  F1 Miniatures Collection Manager"
echo "======================================"

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo "📋 Instale Docker Desktop em: https://docker.com/products/docker-desktop"
    exit 1
fi

# Verificar se Docker Compose está disponível
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose não está disponível!"
    exit 1
fi

echo "✅ Docker está instalado"

# Verificar se os arquivos necessários existem
required_files=("docker-compose.yml" "Dockerfile" "app.py" "requirements.txt")
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ Arquivo necessário não encontrado: $file"
        echo "📋 Certifique-se de que todos os arquivos estão no diretório correto"
        exit 1
    fi
done

echo "✅ Todos os arquivos necessários estão presentes"

# Verificar se as pastas existem
if [[ ! -d "templates" ]] || [[ ! -d "static" ]]; then
    echo "❌ Diretórios templates/ ou static/ não encontrados"
    echo "📋 Criando diretórios..."
    mkdir -p templates static
fi

echo "✅ Estrutura de diretórios OK"

# Função para verificar se a porta está ocupada
check_port() {
    local port=$1
    if command -v lsof &> /dev/null; then
        lsof -ti:$port &> /dev/null
    elif command -v netstat &> /dev/null; then
        netstat -tuln | grep ":$port " &> /dev/null
    else
        # Tentar conectar na porta para testar
        (echo > /dev/tcp/localhost/$port) &>/dev/null
    fi
}

# Verificar se a porta 5000 está ocupada
if check_port 5000; then
    echo "⚠️  Porta 5000 está ocupada!"
    echo "🔍 Verificando o que está usando a porta..."
    
    # Mostrar o processo que está usando a porta
    if command -v lsof &> /dev/null; then
        echo "📋 Processo usando a porta 5000:"
        lsof -ti:5000 | head -1 | xargs ps -p 2>/dev/null | tail -n +2 || echo "   Processo não identificado"
    fi
    
    echo ""
    echo "🛠️  Opções para resolver:"
    echo "   1) Parar o processo atual"
    echo "   2) Usar porta alternativa (5001)"
    echo "   3) Cancelar"
    
    read -p "Escolha uma opção (1/2/3): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            echo "🔧 Tentando liberar a porta 5000..."
            if command -v lsof &> /dev/null; then
                # Pegar o PID do processo na porta 5000
                PID=$(lsof -ti:5000 | head -1)
                if [[ -n "$PID" ]]; then
                    echo "📋 Matando processo PID: $PID"
                    kill -9 $PID 2>/dev/null || sudo kill -9 $PID 2>/dev/null || echo "❌ Não foi possível matar o processo"
                    sleep 2
                    if check_port 5000; then
                        echo "❌ Porta ainda está ocupada. Usando porta alternativa 5001."
                        USE_ALT_PORT=true
                    else
                        echo "✅ Porta 5000 liberada!"
                        USE_ALT_PORT=false
                    fi
                else
                    echo "❌ Não foi possível identificar o processo. Usando porta alternativa."
                    USE_ALT_PORT=true
                fi
            else
                echo "❌ Comando lsof não disponível. Usando porta alternativa."
                USE_ALT_PORT=true
            fi
            ;;
        2)
            echo "🔄 Usando porta alternativa 5001..."
            USE_ALT_PORT=true
            ;;
        3)
            echo "❌ Operação cancelada."
            exit 1
            ;;
        *)
            echo "❌ Opção inválida. Cancelando."
            exit 1
            ;;
    esac
else
    echo "✅ Porta 5000 disponível"
    USE_ALT_PORT=false
fi

# Se precisar usar porta alternativa, modificar o docker-compose temporariamente
if [[ "$USE_ALT_PORT" == "true" ]]; then
    echo "🔧 Configurando para usar porta 5001..."
    
    # Verificar se porta 5001 está livre
    if check_port 5001; then
        echo "❌ Porta 5001 também está ocupada! Tente parar outros serviços primeiro."
        exit 1
    fi
    
    # Criar arquivo docker-compose temporário com porta alternativa
    cp docker-compose.yml docker-compose.yml.backup
    sed 's/"5000:5000"/"5001:5000"/' docker-compose.yml > docker-compose-alt.yml
    COMPOSE_FILE="docker-compose-alt.yml"
    ALT_PORT=5001
else
    COMPOSE_FILE="docker-compose.yml"
    ALT_PORT=5000
fi

# Perguntar se é primeira execução
echo ""
read -p "🤔 É a primeira vez executando? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Construindo e iniciando aplicação (primeira vez)..."
    
    # Usar docker compose ou docker-compose dependendo da versão
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" up --build -d
    else
        docker compose -f "$COMPOSE_FILE" up --build -d
    fi
else
    echo "🚀 Iniciando aplicação..."
    
    # Usar docker compose ou docker-compose dependendo da versão
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$COMPOSE_FILE" up -d
    else
        docker compose -f "$COMPOSE_FILE" up -d
    fi
fi

# Aguardar serviços ficarem prontos
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 10

# Verificar se os containers estão rodando
if command -v docker-compose &> /dev/null; then
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        echo "✅ Aplicação iniciada com sucesso!"
    else
        echo "❌ Erro ao iniciar aplicação"
        docker-compose -f "$COMPOSE_FILE" logs
        exit 1
    fi
else
    if docker compose -f "$COMPOSE_FILE" ps | grep -q "running"; then
        echo "✅ Aplicação iniciada com sucesso!"
    else
        echo "❌ Erro ao iniciar aplicação"
        docker compose -f "$COMPOSE_FILE" logs
        exit 1
    fi
fi

echo ""
echo "🎉 F1 Miniatures está rodando!"
echo "🌐 Acesse: http://localhost:$ALT_PORT"
echo ""
echo "📋 Comandos úteis:"
if [[ "$USE_ALT_PORT" == "true" ]]; then
    echo "   Ver logs:           docker-compose -f docker-compose-alt.yml logs -f"
    echo "   Parar aplicação:    docker-compose -f docker-compose-alt.yml down"
    echo "   Reiniciar:          docker-compose -f docker-compose-alt.yml restart"
    echo ""
    echo "📝 Nota: Usando porta alternativa $ALT_PORT devido à porta 5000 ocupada"
    echo "     Para voltar à porta padrão, pare outros serviços e use docker-compose.yml normal"
else
    echo "   Ver logs:           docker-compose logs -f"
    echo "   Parar aplicação:    docker-compose down"
    echo "   Reiniciar:          docker-compose restart"
fi
echo ""
echo "🏁 Boa diversão gerenciando sua coleção de F1!"

# Limpar arquivo temporário se criado
if [[ -f "docker-compose-alt.yml" ]] && [[ "$USE_ALT_PORT" == "true" ]]; then
    echo ""
    echo "🧹 Arquivo temporário docker-compose-alt.yml criado para porta alternativa"
    echo "   Delete-o quando não precisar mais: rm docker-compose-alt.yml"
fi