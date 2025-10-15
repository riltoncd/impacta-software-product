# 🚀 Início Rápido - F1 Miniatures v1.3 com Upload de Fotos

## ⚡ Setup Rápido (5 minutos)

### Passo 1: Preparar Arquivos

```bash
# Criar estrutura
mkdir -p f1_miniatures/{static/{uploads,images},templates}
cd f1_miniatures

# Copiar TODOS os arquivos dos artifacts desta conversa
# Ver lista completa no artifact "LISTA_DE_ARQUIVOS.md"
```
#
### Passo 2: Criar Diretórios de Upload

```bash
# Criar pastas necessárias
mkdir -p static/uploads static/images

# A imagem padrão (no-image.png) 
# Pode ser copiada do artifact "static/images/no-image.png (SVG)"
# Salve como: static/images/no-image.png
```

### Passo 3: Executar

```bash
# Dar permissões (Linux/Mac)
chmod +x start.sh fix-port.sh

# Iniciar aplicação
./start.sh  # Linux/Mac
# ou
start.bat   # Windows
```

### Passo 4: Usar!

```
🌐 Acesse: http://localhost:5000

✅ Cadastre uma miniatura
📸 Adicione uma foto
🎉 Veja sua coleção visual!
```

---

## 📸 Como Usar o Upload de Fotos

### Ao Cadastrar Nova Miniatura:

1. **Preencha os dados** da miniatura
2. **Clique em "Escolher arquivo"** no campo "Foto da Miniatura"
3. **Selecione uma imagem** (PNG, JPG, JPEG, GIF ou WEBP)
4. **Veja o preview** aparecer automaticamente
5. **Clique em "Adicionar Miniatura"**
6. **Pronto!** A foto aparece no card

### Ao Editar Miniatura Existente:

#### Para Adicionar Foto:
1. Clique em **"✏️ Editar"**
2. Role até **"Adicionar Foto"**
3. **Selecione a imagem**
4. **Salve as alterações**

#### Para Substituir Foto:
1. Clique em **"✏️ Editar"**
2. Veja a **"Foto Atual"** no topo
3. Role até **"Substituir Foto"**
4. **Selecione nova imagem**
5. **Salve** - a foto antiga é removida automaticamente

#### Para Remover Foto:
1. Clique em **"✏️ Editar"**
2. Clique em **"🗑️ Remover Foto"** (botão vermelho)
3. **Confirme**
4. A foto é removida, mas a miniatura permanece

---

## 🎨 Recursos Visuais

### Cards com Fotos
```
┌─────────────────────────┐
│     [FOTO DA MINI]      │ ← Foto em destaque
├─────────────────────────┤
│ Red Bull RB19           │ ← Modelo
├─────────────────────────┤
│ Piloto: Max Verstappen  │
│ Equipe: Red Bull Racing │
│ Ano: 2023 | Escala:1:43 │
├─────────────────────────┤
│ [✏️ Editar] [🗑️ Excluir]│
└─────────────────────────┘
```

### Efeitos Especiais
- **Hover**: Zoom suave na foto ao passar o mouse
- **Preview**: Visualização antes de enviar
- **Padrão**: Ícone 📦 para miniaturas sem foto
- **Validação**: Feedback imediato sobre formato/tamanho

---

## 📋 Formatos e Limites

| Item | Especificação |
|------|---------------|
| **Formatos** | PNG, JPG, JPEG, GIF, WEBP |
| **Tamanho Máximo** | 16 MB por foto |
| **Resolução** | Qualquer (recomendado: 1200x900px) |
| **Nome do arquivo** | Automático com timestamp |
| **Armazenamento** | Volume Docker persistente |

---

## 🔧 Solução Rápida de Problemas

### Foto não aparece após upload

```bash
# Verificar se foi salva
docker-compose exec app ls -la static/uploads/

# Verificar permissões
docker-compose exec app ls -la static/

# Reiniciar
docker-compose restart app
```

### Erro ao fazer upload

```bash
# Ver logs
docker-compose logs -f app

# Verificar espaço em disco
df -h

# Verificar tamanho da foto
ls -lh foto.jpg  # Deve ser < 16MB
```

### Preview não funciona

```bash
# Limpar cache do navegador
Ctrl + Shift + R (Windows/Linux)
Cmd + Shift + R (Mac)

# Verificar console (F12)
# Procurar por erros JavaScript
```

---

## 📊 Checklist de Funcionalidades

- [x] ➕ Cadastrar miniaturas
- [x] 👀 Visualizar coleção
- [x] ✏️ Editar miniaturas
- [x] 🗑️ Excluir miniaturas
- [x] 📸 Upload de fotos
- [x] 🖼️ Preview de fotos
- [x] 🔄 Substituir fotos
- [x] ❌ Remover fotos
- [x] 🏁 Gerenciar equipes
- [ ] 🎥 Vídeos do YouTube (Etapa 4)

---

## 🎯 Dicas de Uso

### Para Melhores Fotos:

1. **Iluminação**: Tire fotos com boa iluminação
2. **Fundo**: Use fundo neutro (branco ou preto)
3. **Ângulo**: Tire de vários ângulos, escolha o melhor
4. **Resolução**: 1200x900px é ideal
5. **Formato**: JPG para fotos normais, PNG para transparência

### Organização:

1. **Adicione foto** ao cadastrar (não deixe para depois)
2. **Use descrição** para detalhes que não cabem na foto
3. **Equipe consistente**: Mantenha nomes padronizados
4. **Backup regular**: Faça backup das fotos

---

## 📦 Arquivos Necessários (v1.3)

### Novos Arquivos:
1. ✨ `migrate_add_photo.py` - Migração do banco
2. ✨ `static/images/no-image.png` - Imagem padrão
3. ✨ Criar pasta: `static/uploads/` - Armazena fotos

### Arquivos Atualizados:
1. 🔄 `models.py` - Campo photo adicionado
2. 🔄 `config.py` - Configurações de upload
3. 🔄 `app.py` - Funções de upload
4. 🔄 `templates/add_miniature.html` - Campo foto
5. 🔄 `templates/edit_miniature.html` - Gerenciar foto
6. 🔄 `templates/index.html` - Exibir fotos
7. 🔄 `static/style.css` - Estilos de fotos
8. 🔄 `static/script.js` - Preview de fotos
9. 🔄 `Dockerfile` - Criar diretórios
10. 🔄 `docker-compose.yml` - Volume de uploads

**Total**: 13 arquivos (3 novos + 10 atualizados)

---

## 🚀 Comandos Úteis

```bash
# Ver fotos armazenadas
docker-compose exec app ls -la static/uploads/

# Ver tamanho total das fotos
docker-compose exec app du -sh static/uploads/

# Backup das fotos
docker run --rm -v f1_miniatures_uploads_data:/uploads \
  -v $(pwd):/backup alpine \
  tar czf /backup/photos_backup.tar.gz /uploads

# Reiniciar aplicação
docker-compose restart app

# Ver logs
docker-compose logs -f app

# Rebuild completo
docker-compose down && docker-compose up --build -d
```

---

## 🎓 Para Apresentação Acadêmica

### Demonstre:
1. ✅ **CRUD completo** funcionando
2. ✅ **Upload de fotos** em tempo real
3. ✅ **Preview** antes do envio
4. ✅ **Validações** de formato e tamanho
5. ✅ **Edição e remoção** de fotos
6. ✅ **Persistência** em volume Docker
7. ✅ **Interface responsiva** com fotos

### Destaque Técnico:
- Backend Python com Flask
- Upload com werkzeug.utils.secure_filename
- Validação de MIME types
- Volume Docker para persistência
- Preview JavaScript com FileReader API
- Timestamps únicos em nomes de arquivo
- Cascata de exclusão (miniatura → foto)

---

## 📞 Suporte Rápido

**Erro comum**: Pasta uploads não existe
```bash
mkdir -p static/uploads static/images
docker-compose restart app
```

**Preview não aparece**: Limpe cache do navegador

**Foto muito grande**: Reduza para < 16MB ou comprima

**Não consegue fazer upload**: Verifique logs
```bash
docker-compose logs app | grep -i error
```

---

**Versão**: 1.3.0  
**Data**: 29/09/2024  
**Status**: Upload de Fotos ✅

🏁 **Sua coleção agora tem fotos!** 📸🏎️