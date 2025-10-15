#!/usr/bin/env python3
"""
Script para criar pastas necessárias
Execute antes de iniciar a aplicação
"""
import os

def setup_folders():
    """Cria todas as pastas necessárias"""
    folders = [
        'static/uploads',
        'static/images',
    ]
    
    for folder in folders:
        os.makedirs(folder, exist_ok=True)
        print(f"✅ Pasta criada/verificada: {folder}")
    
    print("\n🎉 Todas as pastas foram criadas com sucesso!")

if __name__ == '__main__':
    setup_folders()
