# 🚀 Instruções de Atualização para Versão 1.2.0

## Atualização: CRUD Completo com Exclusão de Miniaturas

---

## 📋 O Que Foi Adicionado

### ✨ Nova Funcionalidade: Exclusão de Miniaturas
- Botão "🗑️ Excluir" em cada card de miniatura
- Modal de confirmação com detalhes
- Dupla segurança contra exclusões acidentais
- Mensagens de feedback
- Animações suaves

---

## 🔄 Como Atualizar

### Opção 1: Atualização Sem Perder Dados (Recomendada)

```bash
# 1. Parar a aplicação atual
docker-compose down

# 2. Fazer backup do banco de dados (segurança)
docker-compose up -d db
docker-compose exec db pg_dump -U f1user f1miniatures > backup_pre_1.2.sql
docker-compose down

# 3. Atualizar os arquivos
# Substitua os seguintes arquivos pelos novos:

# - app.py (adicionada rota de exclusão)
# - templates/index.html (adicionado botão excluir e modal)
# - templates/delete_confirm.html (NOVO - opcional)
# - static/style.css (estilos para botão excluir)
# - static/script.js (animações de exclusão)
# - README.md (documentação atualizada)
# - GUIA_DE_USO.md (instruções de exclusão)
# - CHANGELOG.md (NOVO - histórico de versões)
# - ATUALIZAR_PARA_1.2.md (NOVO - este arquivo)

# 4. Reiniciar a aplicação
docker-compose up -d

# 5. Verificar logs
docker-compose logs -f app

# 6. Testar
# Acesse http://localhost:5000 e veja os botões de excluir
```

### Opção 2: Instalação Limpa

```bash
# 1. Backup completo (se tiver dados importantes)
docker-compose exec db pg_dump -U f1user f1miniatures > backup_completo.sql

# 2. Remover tudo
docker-compose down -v

# 3. Atualizar todos os arquivos do projeto

# 4. Rebuild completo
docker-compose up --build -d

# 5. Restaurar dados (se necessário)
docker-compose exec -T db psql -U f1user f1miniatures < backup_completo.sql
```

---

## 📝 Arquivos Novos

Adicione estes arquivos novos ao projeto:

1. **templates/delete_confirm.html** (opcional)
   - Template alternativo para confirmação de exclusão
   - Usado se JavaScript estiver desabilitado

2. **CHANGELOG.md** (recomendado)
   - Histórico completo de versões
   - Útil para documentação acadêmica

3. **ATUALIZAR_PARA_1.2.md** (este arquivo)
   - Instruções de atualização

---

## 📝 Arquivos Modificados

Substitua completamente estes arquivos:

### 1. **app.py**
**Mudanças:**
- Adicionada rota `@app.route('/delete_miniature/<int:id>', methods=['POST'])`
- Tratamento de erros com try-catch
- Rollback automático em caso de falha

**Localização da mudança:**
```python
# Adicionar ANTES da rota @app.route('/api/teams')
@app.route('/delete_miniature/<int:id>', methods=['POST'])
def delete_miniature(id):
    miniature = Miniature.query.get_or_404(id)
    model_name = miniature.model
    
    try:
        db.session.delete(miniature)
        db.session.commit()
        flash(f'Miniatura "{model_name}" excluída com sucesso!', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Erro ao excluir miniatura: {str(e)}', 'error')
    
    return redirect(url_for('index'))
```

### 2. **templates/index.html**
**Mudanças:**
- Rodapé dos cards agora tem grupo de botões
- Adicionado botão "🗑️ Excluir"
- Adicionado modal de confirmação para cada miniatura

**Localização da mudança:**
```html
<!-- Substituir o card-footer completo -->
<div class="card-footer text-muted">
    <div class="d-flex justify-content-between align-items-center">
        <small>Adicionada em {{ miniature.created_at.strftime('%d/%m/%Y') }}</small>
        <div class="btn-group" role="group">
            <a href="{{ url_for('edit_miniature', id=miniature.id) }}" 
               class="btn btn-sm btn-outline-primary">
                ✏️ Editar
            </a>
            <button type="button" 
                    class="btn btn-sm btn-outline-danger"
                    data-bs-toggle="modal" 
                    data-bs-target="#deleteModal{{ miniature.id }}">
                🗑️ Excluir
            </button>
        </div>
    </div>
</div>

<!-- Adicionar modal DEPOIS do </div> do card -->
<!-- Modal de Confirmação -->
<!-- (Ver código completo no arquivo index.html atualizado) -->
```

### 3. **static/style.css**
**Mudanças:**
- Estilos para `.btn-outline-danger`
- Estilos para `.btn-group`
- Estilos para modal de confirmação

**Adicionar ao final:**
```css
.btn-outline-danger {
    color: #dc3545;
    border-color: #dc3545;
}

.btn-outline-danger:hover {
    background-color: #dc3545;
    border-color: #dc3545;
    color: white;
}

.btn-group .btn {
    margin-left: 0.25rem;
}

.modal-header.bg-danger {
    background-color: #dc3545 !important;
}

.modal-body .alert-warning {
    background-color: #fff3cd;
    border-color: #ffc107;
    color: #856404;
}
```

### 4. **static/script.js**
**Mudanças:**
- Adicionadas animações de loading para exclusão
- Animação fadeInUp para cards
- Feedback visual durante exclusão

**Adicionar ao final:**
```javascript
// Confirmação adicional para exclusão
document.addEventListener('DOMContentLoaded', function() {
    const deleteButtons = document.querySelectorAll('.modal-footer .btn-danger');
    
    deleteButtons.forEach(function(button) {
        button.addEventListener('click', function(e) {
            const form = this.closest('form');
            if (form) {
                this.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Excluindo...';
                this.disabled = true;
            }
        });
    });
});

// Animação suave ao carregar cards
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.card');
    cards.forEach(function(card, index) {
        card.style.animation = `fadeInUp 0.5s ease-in-out ${index * 0.1}s both`;
    });
});

// Adicionar keyframes de animação
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
```

### 5. **README.md** e **GUIA_DE_USO.md**
**Mudanças:**
- Atualizada lista de funcionalidades
- Adicionada seção sobre exclusão
- Atualizado roadmap (Etapa 1-2 completa)

---

## ✅ Checklist de Verificação Pós-Atualização

Após atualizar, verifique:

- [ ] Aplicação inicia sem erros
- [ ] Página principal carrega normalmente
- [ ] Botão "🗑️ Excluir" aparece em todos os cards
- [ ] Ao clicar em excluir, modal abre corretamente
- [ ] Modal mostra detalhes da miniatura
- [ ] Botão "Cancelar" fecha o modal sem excluir
- [ ] Botão "Sim, Excluir" remove a miniatura
- [ ] Mensagem de sucesso aparece após exclusão
- [ ] Miniatura desaparece da lista
- [ ] Botão "✏️ Editar" continua funcionando
- [ ] Não há erros no console do navegador
- [ ] Não há erros nos logs do Docker

---

## 🧪 Como Testar a Exclusão

### Teste 1: Exclusão Simples
```bash
1. Acesse http://localhost:5000
2. Cadastre uma miniatura de teste
3. Clique no botão "🗑️ Excluir"
4. Verifique se o modal abre
5. Clique em "Sim, Excluir"
6. Confirme que a miniatura foi removida
```

### Teste 2: Cancelamento
```bash
1. Clique em "🗑️ Excluir" em qualquer miniatura
2. Clique em "Cancelar" no modal
3. Verifique que a miniatura não foi excluída
```

### Teste 3: Fechar Modal
```bash
1. Clique em "🗑️ Excluir"
2. Clique no X do modal ou fora dele
3. Verifique que a miniatura não foi excluída
```

### Teste 4: Múltiplas Exclusões
```bash
1. Cadastre 3 miniaturas de teste
2. Exclua uma por uma
3. Verifique que todas são removidas corretamente
```

---

## 🐛 Solução de Problemas

### Modal não abre
**Causa**: Bootstrap JavaScript não carregou  
**Solução**: Verifique se há erros no console do navegador

### Botão de excluir não aparece
**Causa**: Arquivo index.html não foi atualizado  
**Solução**: Substitua completamente o arquivo

### Erro ao excluir
**Causa**: Rota não foi adicionada ao app.py  
**Solução**: Verifique se a rota delete_miniature existe

### Miniatura não é excluída
**Causa**: Erro no banco de dados  
**Solução**: 
```bash
# Ver logs
docker-compose logs app

# Verificar conexão com banco
docker-compose exec db psql -U f1user -d f1miniatures -c "SELECT * FROM miniatures;"
```

---

## 💾 Backup Antes de Atualizar

**SEMPRE faça backup antes de atualizar!**

```bash
# Backup completo do banco
docker-compose exec db pg_dump -U f1user f1miniatures > backup_$(date +%Y%m%d_%H%M%S).sql

# Verificar o backup
ls -lh backup_*.sql

# Para restaurar se necessário
docker-compose exec -T db psql -U f1user f1miniatures < backup_XXXXXXXX_XXXXXX.sql
```

---

## 📊 Diferenças de Versão

| Feature | v1.1.0 | v1.2.0 |
|---------|--------|--------|
| Cadastrar | ✅ | ✅ |
| Visualizar | ✅ | ✅ |
| Editar | ✅ | ✅ |
| Excluir | ❌ | ✅ ← **NOVO** |
| Modal de Confirmação | ❌ | ✅ ← **NOVO** |
| Animações | Básicas | Avançadas |
| Grupo de Botões | ❌ | ✅ |

---

## 🎯 Próximos Passos

Após atualizar para v1.2.0:

1. **Teste todas as funcionalidades**
2. **Faça backup regular dos dados**
3. **Documente sua coleção**
4. **Aguarde Etapa 3**: Upload de Fotos

---

## 📞 Suporte

Se encontrar problemas:

1. Consulte o **GUIA_DE_USO.md**
2. Veja o **CHANGELOG.md**
3. Execute `docker-compose logs -f app`
4. Tente `docker-compose restart`

---

**Data de Lançamento**: 29/09/2024  
**Versão**: 1.2.0  
**Status**: CRUD Completo ✅