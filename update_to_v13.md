# 🚀 Atualização para Versão 1.3.0 - Upload de Fotos

## 📸 Nova Funcionalidade: Upload de Fotos!

---

## 🎉 O Que Foi Adicionado

### ✨ Funcionalidades de Fotos
- **Upload de fotos** ao cadastrar miniaturas
- **Visualização de fotos** nos cards da coleção
- **Substituir foto** ao editar miniatura
- **Remover foto** individualmente
- **Preview em tempo real** antes do upload
- **Validação de formato** e tamanho de arquivo
- **Imagem padrão** para miniaturas sem foto
- **Persistência de uploads** em volume Docker

### 📋 Formatos Suportados
- PNG
- JPG / JPEG
- GIF
- WEBP
- **Tamanho máximo**: 16MB por foto

---
#
## 🔄 Como Atualizar

### Passo 1: Backup (IMPORTANTE!)

```bash
# Backup do banco de dados
docker-compose exec db pg_dump -U f1user f1miniatures > backup_pre_v1.3_$(date +%Y%m%d).sql

# Backup das fotos (se já tiver alguma)
cp -r static/uploads backup_uploads_$(date +%Y%m%d)
```

### Passo 2: Parar Aplicação

```bash
docker-compose down
```

### Passo 3: Atualizar Arquivos

**Arquivos NOVOS para criar:**
- `migrate_add_photo.py` (script de migração)
- `static/images/no-image.png` (imagem padrão SVG)

**Arquivos para SUBSTITUIR:**
- `models.py` (+ campo photo e métodos)
- `config.py` (+ configurações de upload)
- `app.py` (+ funções de upload)
- `templates/add_miniature.html` (+ campo de foto)
- `templates/edit_miniature.html` (+ gerenciamento de foto)
- `templates/index.html` (+ exibição de fotos)
- `static/style.css` (+ estilos para fotos)
- `static/script.js` (+ preview de fotos)
- `Dockerfile` (+ criação de diretórios)
- `docker-compose.yml` (+ volume para uploads)

### Passo 4: Criar Diretórios

```bash
# Criar pasta para uploads
mkdir -p static/uploads static/images

# Copiar imagem padrão (no-image.png)
# Salve o SVG do artifact como static/images/no-image.png
```

### Passo 5: Rebuild e Migrar

```bash
# Rebuild da aplicação
docker-compose up --build -d

# A migração roda automaticamente no startup
# Verifique os logs
docker-compose logs -f app

# Deve mostrar:
# ✅ Coluna 'photo' adicionada com sucesso!
# ✅ Coluna 'updated_at' adicionada com sucesso!
# 🎉 Migração concluída com sucesso!
```

### Passo 6: Verificar

```bash
# Verificar se diretórios foram criados
docker-compose exec app ls -la static/

# Deve mostrar:
# drwxr-xr-x uploads/
# drwxr-xr-x images/

# Testar aplicação
curl http://localhost:5000
```

---

## 🧪 Testando as Novas Funcionalidades

### Teste 1: Upload de Foto ao Cadastrar

```bash
1. Acesse http://localhost:5000
2. Clique em "Adicionar Miniatura"
3. Preencha os campos obrigatórios
4. Clique em "Escolher arquivo" no campo "Foto"
5. Selecione uma imagem (PNG, JPG, etc)
6. Veja o PREVIEW da foto aparecer
7. Clique em "Adicionar Miniatura"
8. Verifique que a foto aparece no card!
```

### Teste 2: Editar e Substituir Foto

```bash
1. Clique em "Editar" em uma miniatura que tem foto
2. Veja a "Foto Atual" no topo
3. Selecione uma NOVA foto no campo "Substituir Foto"
4. Veja o preview da nova foto
5. Clique em "Salvar Alterações"
6. Verifique que a foto foi atualizada!
```

### Teste 3: Remover Foto

```bash
1. Clique em "Editar" em uma miniatura com foto
2. Clique no botão "Remover Foto" (vermelho)
3. Confirme a remoção
4. A foto é removida, mas a miniatura permanece
5. Você pode adicionar uma nova foto depois
```

### Teste 4: Miniatura Sem Foto

```bash
1. Cadastre uma miniatura SEM selecionar foto
2. Verifique que aparece o ícone 📦 e "Sem foto"
3. Edite a miniatura
4. Adicione uma foto
5. Salve e veja a foto no card
```

---

## 📂 Estrutura de Arquivos Atualizada

```
f1_miniatures/
├── models.py                    # ✨ ATUALIZADO
├── config.py                    # ✨ ATUALIZADO
├── app.py                       # ✨ ATUALIZADO
├── migrate_add_photo.py         # 🆕 NOVO
├── Dockerfile                   # ✨ ATUALIZADO
├── docker-compose.yml           # ✨ ATUALIZADO
├── static/
│   ├── style.css                # ✨ ATUALIZADO
│   ├── script.js                # ✨ ATUALIZADO
│   ├── uploads/                 # 🆕 NOVO (pasta de fotos)
│   └── images/
│       └── no-image.png         # 🆕 NOVO
└── templates/
    ├── add_miniature.html       # ✨ ATUALIZADO
    ├── edit_miniature.html      # ✨ ATUALIZADO
    └── index.html               # ✨ ATUALIZADO
```

---

## 🔧 Migração Manual (Se Necessário)

Se a migração automática falhar, execute manualmente:

```bash
# Conectar no banco
docker-compose exec db psql -U f1user -d f1miniatures

# Adicionar coluna photo
ALTER TABLE miniatures ADD COLUMN photo VARCHAR(255);

# Adicionar coluna updated_at
ALTER TABLE miniatures ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

# Atualizar valores existentes
UPDATE miniatures SET updated_at = created_at WHERE updated_at IS NULL;

# Sair
\q
```

---

## 💾 Gestão de Uploads

### Onde Ficam as Fotos?

```bash
# No container
/app/static/uploads/

# No host (via volume)
Volume Docker: uploads_data

# Para acessar
docker-compose exec app ls -la /app/static/uploads/
```

### Backup de Fotos

```bash
# Criar backup das fotos
docker run --rm -v f1_miniatures_uploads_data:/uploads -v $(pwd):/backup alpine tar czf /backup/uploads_backup_$(date +%Y%m%d).tar.gz /uploads

# Restaurar backup
docker run --rm -v f1_miniatures_uploads_data:/uploads -v $(pwd):/backup alpine tar xzf /backup/uploads_backup_XXXXXXXX.tar.gz -C /
```

### Limpar Uploads Órfãos

```bash
# Ver fotos no disco
docker-compose exec app ls -la static/uploads/

# Limpar fotos não referenciadas no banco
docker-compose exec app python -c "
from app import app
from models import db, Miniature
import os

with app.app_context():
    # Pegar todas as fotos no banco
    photos_in_db = set(m.photo for m in Miniature.query.all() if m.photo)
    
    # Pegar todas as fotos no disco
    uploads_dir = 'static/uploads'
    photos_on_disk = set(os.listdir(uploads_dir))
    
    # Encontrar órfãs
    orphans = photos_on_disk - photos_in_db
    
    print(f'Fotos órfãs: {len(orphans)}')
    for photo in orphans:
        print(f'  - {photo}')
"
```

---

## 🐛 Problemas Comuns

### Erro: "No such file or directory: 'static/uploads'"

**Solução:**
```bash
# Criar diretório manualmente
mkdir -p static/uploads static/images

# Rebuild
docker-compose down
docker-compose up --build
```

### Erro: "413 Request Entity Too Large"

**Causa:** Foto maior que 16MB

**Solução:**
- Reduza o tamanho da foto
- Ou aumente MAX_CONTENT_LENGTH em config.py

### Foto não aparece após upload

**Verificar:**
```bash
# 1. Ver se foto foi salva
docker-compose exec app ls -la static/uploads/

# 2. Ver se está no banco
docker-compose exec db psql -U f1user -d f1miniatures -c "SELECT id, model, photo FROM miniatures WHERE photo IS NOT NULL;"

# 3. Ver permissões
docker-compose exec app ls -la static/uploads/nome_da_foto.jpg
```

### Preview não funciona

**Causa:** JavaScript não carregou

**Solução:**
```bash
# Limpar cache do navegador
Ctrl + Shift + R

# Verificar console do navegador
F12 → Console → Ver erros
```

---

## 📊 Estatísticas da Versão 1.3

| Funcionalidade | Status |
|----------------|--------|
| Upload de fotos | ✅ |
| Preview em tempo real | ✅ |
| Editar foto | ✅ |
| Remover foto | ✅ |
| Validação de formato | ✅ |
| Validação de tamanho | ✅ |
| Persistência | ✅ |
| Imagem padrão | ✅ |

---

## 🎯 Próxima Etapa

**Versão 1.4 - Vídeos do YouTube**
- Adicionar link de vídeo do YouTube
- Embed de vídeos nas miniaturas
- Preview de vídeos
- Playlist da coleção

---

## ✅ Checklist de Atualização

- [ ] Backup do banco de dados criado
- [ ] Backup de fotos existentes (se houver)
- [ ] Todos os arquivos atualizados
- [ ] Diretórios static/uploads e static/images criados
- [ ] Imagem no-image.png adicionada
- [ ] Docker rebuild executado
- [ ] Migração do banco concluída
- [ ] Aplicação acessível em http://localhost:5000
- [ ] Upload de foto testado e funcionando
- [ ] Edição de foto testada e funcionando
- [ ] Remoção de foto testada e funcionando
- [ ] Fotos aparecem nos cards corretamente

---

**Data de Lançamento**: 29/09/2024  
**Versão**: 1.3.0  
**Status**: Upload de Fotos Implementado ✅

🏁 **Aproveite as fotos na sua coleção de F1!** 📸