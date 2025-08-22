# F1 Miniatures Collection Manager - Etapa 1

Sistema para gerenciar coleção de miniaturas de carros de Fórmula 1.

## Funcionalidades da Etapa 1:
- ✅ Cadastro de miniaturas (modelo, descrição, piloto)
- ✅ Cadastro de equipes de F1
- ✅ Suporte a equipes personalizadas
- ✅ Interface web responsiva
- ✅ Banco de dados PostgreSQL

## Pré-requisitos:
- Python 3.8 ou superior
- PostgreSQL 12 ou superior

---

## Instalação por Sistema Operacional

### 🐧 Linux (Ubuntu/Debian)

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Python e PostgreSQL
sudo apt install python3 python3-pip python3-venv postgresql postgresql-contrib -y

# 3. Configurar PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 4. Criar usuário e banco de dados
sudo -u postgres psql
CREATE USER f1user WITH PASSWORD 'f1password';
CREATE DATABASE f1miniatures OWNER f1user;
GRANT ALL PRIVILEGES ON DATABASE f1miniatures TO f1user;
\q

# 5. Clonar/baixar o projeto e entrar no diretório
cd f1_miniatures

# 6. Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# 7. Instalar dependências
pip install -r requirements.txt

# 8. Inicializar banco de dados
python init_db.py

# 9. Executar aplicação
python app.py
```

### 🍎 macOS

```bash
# 1. Instalar Homebrew (se não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Instalar Python e PostgreSQL
brew install python postgresql

# 3. Iniciar PostgreSQL
brew services start postgresql

# 4. Criar usuário e banco de dados
psql postgres
CREATE USER f1user WITH PASSWORD 'f1password';
CREATE DATABASE f1miniatures OWNER f1user;
GRANT ALL PRIVILEGES ON DATABASE f1miniatures TO f1user;
\q

# 5. Clonar/baixar o projeto e entrar no diretório
cd f1_miniatures

# 6. Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# 7. Instalar dependências
pip install -r requirements.txt

# 8. Inicializar banco de dados
python init_db.py

# 9. Executar aplicação
python app.py
```

### 🪟 Windows

```cmd
# 1. Baixar e instalar Python 3.8+ de https://python.org
# 2. Baixar e instalar PostgreSQL de https://postgresql.org

# 3. Abrir Command Prompt como Administrador

# 4. Configurar PostgreSQL (substituir CAMINHO_POSTGRESQL pelo caminho real)
cd "C:\Program Files\PostgreSQL\15\bin"
psql -U postgres
CREATE USER f1user WITH PASSWORD 'f1password';
CREATE DATABASE f1miniatures OWNER f1user;
GRANT ALL PRIVILEGES ON DATABASE f1miniatures TO f1user;
\q

# 5. Navegar até o diretório do projeto
cd C:\caminho\para\f1_miniatures

# 6. Criar ambiente virtual
python -m venv venv
venv\Scripts\activate

# 7. Instalar dependências
pip install -r requirements.txt

# 8. Inicializar banco de dados
python init_db.py

# 9. Executar aplicação
python app.py
```

---

## 🐳 Configuração com Docker (Recomendada - Todos os SOs)

### **Vantagens do Docker:**
- ✅ Não precisa instalar PostgreSQL manualmente
- ✅ Funciona igual em Windows, Linux e macOS
- ✅ Ambiente isolado e reproduzível
- ✅ Configuração automática do banco de dados

### **Pré-requisitos Docker:**
- Docker Desktop (Windows/Mac) ou Docker Engine (Linux)
- Docker Compose

---

### **Instalação do Docker por Sistema:**

#### 🪟 **Windows:**
1. Baixar **Docker Desktop** de https://docker.com/products/docker-desktop
2. Instalar e reiniciar o computador
3. Abrir Docker Desktop e aguardar inicialização

#### 🐧 **Linux (Ubuntu/Debian):**
```bash
# Instalar Docker
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker

# Adicionar usuário ao grupo docker (opcional)
sudo usermod -aG docker $USER
# Logout e login novamente
```

#### 🍎 **macOS:**
1. Baixar **Docker Desktop** de https://docker.com/products/docker-desktop
2. Instalar arrastando para Applications
3. Abrir Docker Desktop

---

### **📋 Passos Detalhados para Rodar com Docker:**

#### **1. Preparar Arquivos**
```bash
# Criar diretório do projeto
mkdir f1_miniatures
cd f1_miniatures

# Criar estrutura de diretórios
mkdir templates static
```

#### **2. Criar docker-compose.yml**
Crie o arquivo `docker-compose.yml` na raiz do projeto:

```yaml
version: '3.8'

services:
  # Banco de dados PostgreSQL
  db:
    image: postgres:15-alpine
    container_name: f1_postgres
    environment:
      POSTGRES_DB: f1miniatures
      POSTGRES_USER: f1user
      POSTGRES_PASSWORD: f1password
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U f1user -d f1miniatures"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - f1_network

  # Aplicação Flask
  app:
    build: .
    container_name: f1_app
    ports:
      - "5000:5000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://f1user:f1password@db:5432/f1miniatures
      FLASK_ENV: development
      FLASK_DEBUG: "True"
    volumes:
      - .:/app  # Para desenvolvimento (hot reload)
    networks:
      - f1_network
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local

networks:
  f1_network:
    driver: bridge
```

#### **3. Adicionar todos os arquivos do projeto**
Certifique-se de que todos os arquivos estão na estrutura correta:
```
f1_miniatures/
├── docker-compose.yml    ← Arquivo Docker
├── Dockerfile           ← Arquivo Docker
├── app.py
├── models.py
├── config.py
├── requirements.txt
├── init_db.py
├── static/
│   ├── style.css
│   └── script.js
└── templates/
    ├── base.html
    ├── index.html
    ├── add_miniature.html
    └── add_team.html
```

#### **4. Executar a Aplicação**

##### **🚀 Primeira execução (build e run):**
```bash
# Navegar até o diretório do projeto
cd f1_miniatures

# Construir e executar todos os serviços
docker-compose up --build

# Ou em modo detached (em background)
docker-compose up --build -d
```

##### **⚡ Execuções posteriores:**
```bash
# Apenas executar (sem rebuild)
docker-compose up

# Ou em background
docker-compose up -d
```

#### **5. Acessar a Aplicação**
- **URL**: http://localhost:5000
- **Banco**: localhost:5432 (se precisar conectar diretamente)

---

### **🛠️ Comandos Úteis do Docker:**

#### **Gerenciamento de Containers:**
```bash
# Ver containers rodando
docker-compose ps

# Ver logs da aplicação
docker-compose logs app

# Ver logs do banco
docker-compose logs db

# Ver logs em tempo real
docker-compose logs -f

# Parar todos os serviços
docker-compose down

# Parar e remover volumes (CUIDADO: apaga dados!)
docker-compose down -v
```

#### **Desenvolvimento e Debug:**
```bash
# Reconstruir apenas a aplicação
docker-compose build app

# Executar comandos dentro do container
docker-compose exec app bash

# Executar comandos no banco
docker-compose exec db psql -U f1user -d f1miniatures

# Reiniciar apenas a aplicação
docker-compose restart app
```

#### **Backup e Manutenção:**
```bash
# Backup do banco de dados
docker-compose exec db pg_dump -U f1user f1miniatures > backup.sql

# Restaurar backup
docker-compose exec -T db psql -U f1user f1miniatures < backup.sql

# Ver uso de espaço
docker system df

# Limpar containers não utilizados
docker system prune
```

---

### **🔧 Resolução de Problemas Docker:**

#### **Problema: "Port already in use" (Porta já está em uso)**

**Solução Automática (Recomendada):**
```bash
# O script start.sh agora detecta automaticamente e oferece opções
./start.sh  # Ele vai perguntar como resolver
```

**Solução Manual:**
```bash
# 1. Usar script específico para resolver conflitos
chmod +x fix-port.sh
./fix-port.sh

# 2. Verificar o que está usando a porta
sudo lsof -i :5000

# 3. Matar processo específico
sudo kill -9 PID_DO_PROCESSO

# 4. Ou usar porta alternativa manualmente
# Editar docker-compose.yml:
# ports:
#   - "5001:5000"  # Em vez de "5000:5000"
```

**Causas Comuns:**
- ✋ Outro container F1 Miniatures rodando
- ✋ Flask/Django rodando localmente
- ✋ Outro serviço web na porta 5000
- ✋ AirPlay no macOS (usa porta 5000)

**Desabilitar AirPlay no macOS:**
```bash
# Ir em: System Preferences > Sharing > AirPlay Receiver
# Ou temporariamente:
sudo lsof -ti :5000 | xargs sudo kill -9
```

#### **Problema: "Database connection failed"**
```bash
# Verificar se o PostgreSQL está rodando
docker-compose ps

# Ver logs do banco
docker-compose logs db

# Reiniciar banco
docker-compose restart db
```

#### **Problema: "Build failed"**
```bash
# Limpar cache do Docker
docker builder prune

# Reconstruir do zero
docker-compose build --no-cache
docker-compose up
```

#### **Problema: Alterações no código não aparecem**
```bash
# Verificar se o volume está mapeado
docker-compose exec app ls -la /app

# Reiniciar aplicação
docker-compose restart app

# Ou rebuild se mudou dependências
docker-compose build app
```

---

### **🎯 Vantagens da Versão Docker:**

1. **Instalação Simplificada**: Um comando para tudo
2. **Ambiente Consistente**: Funciona igual em qualquer máquina
3. **Isolamento**: Não interfere com outros projetos
4. **PostgreSQL Automático**: Banco configurado automaticamente
5. **Hot Reload**: Mudanças no código aparecem automaticamente
6. **Fácil Reset**: `docker-compose down -v` limpa tudo

---

### **📝 Workflow de Desenvolvimento com Docker:**

1. **Primeira vez:**
   ```bash
   docker-compose up --build -d
   ```

2. **Desenvolvimento diário:**
   ```bash
   # Iniciar
   docker-compose up -d
   
   # Parar ao final do dia
   docker-compose down
   ```

3. **Ver logs durante desenvolvimento:**
   ```bash
   docker-compose logs -f app
   ```

4. **Reset completo (se algo der errado):**
   ```bash
   docker-compose down -v
   docker-compose up --build
   ```

---

## Uso da Aplicação

1. **Acesse**: http://localhost:5000
2. **Adicionar Equipe**: Clique em "Adicionar Equipe" para cadastrar novas equipes
3. **Adicionar Miniatura**: Clique em "Adicionar Miniatura" para cadastrar suas miniaturas
4. **Visualizar Coleção**: A página inicial mostra todas as miniaturas cadastradas

## Estrutura de Dados

### Equipes (teams)
- Nome da equipe
- País
- Flag para equipes personalizadas

### Miniaturas (miniatures)
- Modelo
- Descrição
- Piloto
- Equipe (relacionamento)
- Ano
- Escala
- Data de cadastro

## Próximas Etapas

- **Etapa 2**: Editar e excluir registros
- **Etapa 3**: Upload e gerenciamento de fotos
- **Etapa 4**: Integração com vídeos do YouTube

## Estrutura do Projeto

```
f1_miniatures/
├── app.py                 # Aplicação principal Flask
├── models.py             # Modelos do banco de dados
├── config.py             # Configurações
├── requirements.txt      # Dependências Python
├── init_db.py           # Script para inicializar o banco
├── static/              # Arquivos estáticos (CSS, JS)
│   ├── style.css
│   └── script.js
├── templates/           # Templates HTML
│   ├── base.html
│   ├── index.html
│   ├── add_miniature.html
│   └── add_team.html
└── README.md           # Instruções de instalação
```

## Problemas Comuns

### Erro de Conexão com PostgreSQL:
1. Verifique se o PostgreSQL está rodando
2. Confirme usuário e senha
3. Teste conexão: `psql -U f1user -d f1miniatures -h localhost`

### Erro "Module not found":
1. Ative o ambiente virtual: `source venv/bin/activate` (Linux/Mac) ou `venv\Scripts\activate` (Windows)
2. Reinstale dependências: `pip install -r requirements.txt`

### Porta 5000 ocupada:
1. Mate processo: `sudo lsof -ti:5000 | xargs kill -9`
2. Ou mude a porta no arquivo `app.py`

## Tecnologias Utilizadas

- **Backend**: Python 3.8+ + Flask 2.3.3
- **Database**: PostgreSQL 12+
- **Frontend**: HTML5 + Bootstrap 5 + JavaScript
- **ORM**: SQLAlchemy
- **Styling**: CSS customizado com tema F1

## Features Implementadas

### ✅ Cadastro de Miniaturas
- Modelo obrigatório
- Descrição opcional
- Piloto opcional
- Seleção de equipe ou equipe personalizada
- Ano e escala opcionais

### ✅ Gerenciamento de Equipes
- Cadastro de novas equipes
- Equipes F1 oficiais pré-carregadas
- Suporte a equipes personalizadas
- Relacionamento com miniaturas

### ✅ Interface Responsiva
- Design moderno inspirado na F1
- Compatível com mobile, tablet e desktop
- Mensagens de feedback
- Validação de formulários

### ✅ Banco de Dados Robusto
- PostgreSQL (não SQLite)
- Relacionamentos adequados
- Migrações automáticas
- Dados iniciais

---

**Desenvolvido para disciplina acadêmica - Etapa 1/4**

## Licença

Este projeto é desenvolvido para fins acadêmicos.