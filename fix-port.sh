#!/bin/bash

# Script para resolver conflitos de porta para F1 Miniatures
set -e

echo "🔧 F1 Miniatures - Resolver Conflitos de Porta"
echo "=============================================="

# Função para verificar se a porta está ocupada
check_port() {
    local port=$1
    if command -v lsof &> /dev/null; then
        lsof -ti:$port &> /dev/null
    elif command -v netstat &> /dev/null; then
        netstat -tuln | grep ":$port " &> /dev/null
    else
        (echo > /dev/tcp/localhost/$port) &>/dev/null
    fi
}
#
# Verificar porta 5000
echo "🔍 Verificando porta 5000..."
if check_port 5000; then
    echo "⚠️  Porta 5000 está ocupada!"
    
    # Identificar o processo
    if command -v lsof &> /dev/null; then
        echo "📋 Processos usando a porta 5000:"
        lsof -i:5000 | head -10
        echo ""
        
        # Listar PIDs
        PIDS=$(lsof -ti:5000)
        echo "🔢 PIDs encontrados: $PIDS"
        
        # Tentar identificar se é outro container Docker
        for PID in $PIDS; do
            PROCESS_NAME=$(ps -p $PID -o comm= 2>/dev/null || echo "desconhecido")
            PROCESS_CMD=$(ps -p $PID -o args= 2>/dev/null || echo "desconhecido")
            echo "   PID $PID: $PROCESS_NAME"
            echo "   Comando: $PROCESS_CMD"
            echo ""
            
            # Verificar se é um container Docker
            if echo "$PROCESS_CMD" | grep -q "docker\|container"; then
                echo "   🐳 Este parece ser um container Docker!"
                echo "   💡 Sugestão: docker ps -a | grep 5000"
                echo "   💡 Para parar: docker stop <container_name>"
                echo ""
            fi
        done
        
        echo "🛠️  Opções:"
        echo "   1) Matar todos os processos na porta 5000"
        echo "   2) Matar processo específico"
        echo "   3) Ver containers Docker usando a porta"
        echo "   4) Usar porta alternativa (5001)"
        echo "   5) Cancelar"
        
        read -p "Escolha uma opção (1-5): " -n 1 -r
        echo
        
        case $REPLY in
            1)
                echo "💥 Matando todos os processos na porta 5000..."
                for PID in $PIDS; do
                    echo "   Matando PID: $PID"
                    kill -9 $PID 2>/dev/null || sudo kill -9 $PID 2>/dev/null || echo "   ❌ Falha ao matar PID $PID"
                done
                sleep 2
                if check_port 5000; then
                    echo "❌ Alguns processos ainda estão rodando na porta 5000"
                else
                    echo "✅ Porta 5000 liberada!"
                fi
                ;;
            2)
                echo "🎯 Digite o PID que deseja matar:"
                read -p "PID: " TARGET_PID
                if [[ "$TARGET_PID" =~ ^[0-9]+$ ]]; then
                    echo "💥 Matando PID: $TARGET_PID"
                    kill -9 $TARGET_PID 2>/dev/null || sudo kill -9 $TARGET_PID 2>/dev/null || echo "❌ Falha ao matar PID"
                    sleep 1
                    if check_port 5000; then
                        echo "⚠️  Porta 5000 ainda está ocupada"
                    else
                        echo "✅ Porta 5000 liberada!"
                    fi
                else
                    echo "❌ PID inválido"
                fi
                ;;
            3)
                echo "🐳 Verificando containers Docker..."
                echo ""
                echo "📋 Todos os containers:"
                docker ps -a
                echo ""
                echo "📋 Containers usando porta 5000:"
                docker ps --filter "publish=5000" 2>/dev/null || echo "   Nenhum encontrado"
                echo ""
                echo "💡 Para parar um container: docker stop <container_name_or_id>"
                echo "💡 Para remover um container: docker rm <container_name_or_id>"
                ;;
            4)
                echo "🔄 Usando porta alternativa..."
                echo "📝 Isso será configurado automaticamente pelo start.sh"
                ;;
            5)
                echo "❌ Cancelado"
                exit 0
                ;;
            *)
                echo "❌ Opção inválida"
                ;;
        esac
    else
        echo "❌ Comando lsof não disponível. Tente instalar com:"
        echo "   Ubuntu/Debian: sudo apt install lsof"
        echo "   CentOS/RHEL: sudo yum install lsof"
        echo "   macOS: brew install lsof"
    fi
else
    echo "✅ Porta 5000 está livre!"
fi

echo ""
echo "🔍 Verificando porta 5432 (PostgreSQL)..."
if check_port 5432; then
    echo "⚠️  Porta 5432 está ocupada!"
    echo "📋 Isso pode ser um PostgreSQL local rodando"
    
    if command -v lsof &> /dev/null; then
        echo "📋 Processos usando a porta 5432:"
        lsof -i:5432
        echo ""
    fi
    
    echo "💡 Opções:"
    echo "   - Parar PostgreSQL local: sudo systemctl stop postgresql"
    echo "   - Ou modificar docker-compose.yml para usar porta diferente"
    echo "   - Exemplo: '5433:5432' no lugar de '5432:5432'"
else
    echo "✅ Porta 5432 está livre!"
fi

echo ""
echo "🎯 Comandos úteis para debug:"
echo "   Ver todas as portas ocupadas: netstat -tuln"
echo "   Ver processos por porta: lsof -i:<porta>"
echo "   Ver containers Docker: docker ps -a"
echo "   Ver logs do Docker: docker-compose logs"
echo ""
echo "🏁 Execute ./start.sh novamente após resolver os conflitos!"