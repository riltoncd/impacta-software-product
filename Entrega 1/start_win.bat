@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo 🏎️  F1 Miniatures Collection Manager
echo ======================================

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo ❌ Docker não está instalado!
    echo 📋 Instale Docker Desktop em: https://docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo ✅ Docker está instalado

REM Verificar arquivos necessários
set "files=docker-compose.yml Dockerfile app.py requirements.txt"
for %%f in (!files!) do (
    if not exist "%%f" (
        echo ❌ Arquivo necessário não encontrado: %%f
        echo 📋 Certifique-se de que todos os arquivos estão no diretório correto
        pause
        exit /b 1
    )
)

echo ✅ Todos os arquivos necessários estão presentes

REM Verificar se as pastas existem
if not exist "templates" mkdir templates
if not exist "static" mkdir static

echo ✅ Estrutura de diretórios OK

REM Verificar se a porta 5000 está ocupada
netstat -an | find "LISTENING" | find ":5000" >nul
if !ERRORLEVEL! EQU 0 (
    echo ⚠️  Porta 5000 está ocupada!
    echo 🔍 Verificando o que está usando a porta...
    netstat -ano | find ":5000"
    echo.
    echo 🛠️  Opções para resolver:
    echo    1^) Parar o processo atual
    echo    2^) Usar porta alternativa ^(5001^)
    echo    3^) Cancelar
    echo.
    set /p "option=Escolha uma opção (1/2/3): "
    
    if "!option!"=="1" (
        echo 🔧 Tentando liberar a porta 5000...
        for /f "tokens=5" %%a in ('netstat -ano ^| find ":5000" ^| find "LISTENING"') do (
            echo 📋 Matando processo PID: %%a
            taskkill /PID %%a /F >nul 2>&1
        )
        timeout /t 2 /nobreak >nul
        netstat -an | find "LISTENING" | find ":5000" >nul
        if !ERRORLEVEL! EQU 0 (
            echo ❌ Porta ainda está ocupada. Usando porta alternativa 5001.
            set "USE_ALT_PORT=true"
        ) else (
            echo ✅ Porta 5000 liberada!
            set "USE_ALT_PORT=false"
        )
    ) else if "!option!"=="2" (
        echo 🔄 Usando porta alternativa 5001...
        set "USE_ALT_PORT=true"
    ) else (
        echo ❌ Operação cancelada.
        pause
        exit /b 1
    )
) else (
    echo ✅ Porta 5000 disponível
    set "USE_ALT_PORT=false"
)

REM Se precisar usar porta alternativa
if "!USE_ALT_PORT!"=="true" (
    echo 🔧 Configurando para usar porta 5001...
    
    REM Verificar se porta 5001 está livre
    netstat -an | find "LISTENING" | find ":5001" >nul
    if !ERRORLEVEL! EQU 0 (
        echo ❌ Porta 5001 também está ocupada! Tente parar outros serviços primeiro.
        pause
        exit /b 1
    )
    
    REM Criar arquivo docker-compose temporário com porta alternativa
    copy docker-compose.yml docker-compose.yml.backup >nul
    powershell -Command "(Get-Content docker-compose.yml) -replace '\"5000:5000\"', '\"5001:5000\"' | Set-Content docker-compose-alt.yml"
    set "COMPOSE_FILE=docker-compose-alt.yml"
    set "ALT_PORT=5001"
) else (
    set "COMPOSE_FILE=docker-compose.yml"
    set "ALT_PORT=5000"
)

REM Perguntar se é primeira execução
echo.
set /p "first=🤔 É a primeira vez executando? (y/n): "
if /i "!first!"=="y" (
    echo 🔨 Construindo e iniciando aplicação primeira vez...
    docker-compose -f "!COMPOSE_FILE!" up --build -d
) else (
    echo 🚀 Iniciando aplicação...
    docker-compose -f "!COMPOSE_FILE!" up -d
)

REM Aguardar serviços ficarem prontos
echo ⏳ Aguardando serviços ficarem prontos...
timeout /t 10 /nobreak >nul

REM Verificar se os containers estão rodando
docker-compose -f "!COMPOSE_FILE!" ps | find "Up" >nul
if !ERRORLEVEL! EQU 0 (
    echo ✅ Aplicação iniciada com sucesso!
) else (
    echo ❌ Erro ao iniciar aplicação
    docker-compose -f "!COMPOSE_FILE!" logs
    pause
    exit /b 1
)

echo.
echo 🎉 F1 Miniatures está rodando!
echo 🌐 Acesse: http://localhost:!ALT_PORT!
echo.
echo 📋 Comandos úteis:
if "!USE_ALT_PORT!"=="true" (
    echo    Ver logs:           docker-compose -f docker-compose-alt.yml logs -f
    echo    Parar aplicação:    docker-compose -f docker-compose-alt.yml down
    echo    Reiniciar:          docker-compose -f docker-compose-alt.yml restart
    echo.
    echo 📝 Nota: Usando porta alternativa !ALT_PORT! devido à porta 5000 ocupada
    echo      Para voltar à porta padrão, pare outros serviços e use docker-compose.yml normal
) else (
    echo    Ver logs:           docker-compose logs -f
    echo    Parar aplicação:    docker-compose down
    echo    Reiniciar:          docker-compose restart
)
echo.
echo 🏁 Boa diversão gerenciando sua coleção de F1!

if "!USE_ALT_PORT!"=="true" (
    echo.
    echo 🧹 Arquivo temporário docker-compose-alt.yml criado para porta alternativa
    echo    Delete-o quando não precisar mais: del docker-compose-alt.yml
)
echo.
pause