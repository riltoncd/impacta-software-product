#!/usr/bin/env python3
"""
Script de migração para adicionar coluna 'photo' e 'updated_at' na tabela miniatures
Execute: python migrate_add_photo.py
"""

from app import app
from models import db
from sqlalchemy import text
#
def migrate():
    with app.app_context():
        try:
            # Verificar se a coluna 'photo' já existe
            result = db.session.execute(text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='miniatures' AND column_name='photo';
            """))
            
            if not result.fetchone():
                print("Adicionando coluna 'photo' na tabela miniatures...")
                db.session.execute(text("""
                    ALTER TABLE miniatures 
                    ADD COLUMN photo VARCHAR(255);
                """))
                db.session.commit()
                print("✅ Coluna 'photo' adicionada com sucesso!")
            else:
                print("ℹ️  Coluna 'photo' já existe.")
            
            # Verificar se a coluna 'updated_at' já existe
            result = db.session.execute(text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='miniatures' AND column_name='updated_at';
            """))
            
            if not result.fetchone():
                print("Adicionando coluna 'updated_at' na tabela miniatures...")
                db.session.execute(text("""
                    ALTER TABLE miniatures 
                    ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
                """))
                
                # Atualizar valores existentes
                db.session.execute(text("""
                    UPDATE miniatures 
                    SET updated_at = created_at 
                    WHERE updated_at IS NULL;
                """))
                
                db.session.commit()
                print("✅ Coluna 'updated_at' adicionada com sucesso!")
            else:
                print("ℹ️  Coluna 'updated_at' já existe.")
            
            print("\n🎉 Migração concluída com sucesso!")
            print("📸 Agora você pode adicionar fotos às suas miniaturas!")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Erro na migração: {e}")
            raise

if __name__ == '__main__':
    migrate()
