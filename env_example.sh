# Configurações da aplicação F1 Miniatures
# Copie este arquivo para .env e ajuste as configurações

# Chave secreta para sessões Flask (gere uma aleatória para produção)
SECRET_KEY=dev-secret-key-f1-miniatures

# URL de conexão com o banco PostgreSQL
# Formato: postgresql://usuario:senha@host:porta/nome_banco
DATABASE_URL=postgresql://f1user:f1password@localhost:5432/f1miniatures

# Configurações opcionais
FLASK_ENV=development
FLASK_DEBUG=True
#