# 📝 Changelog - F1 Miniatures Collection Manager

Histórico de versões e atualizações do projeto.

---

## [1.2.0] - 2024-09-29 - CRUD COMPLETO ✅

### ✨ Adicionado
- **Funcionalidade de Exclusão de Miniaturas**
  - Modal de confirmação com detalhes da miniatura
  - Botão "🗑️ Excluir" em cada card
  - Dupla segurança contra exclusões acidentais
  - Mensagens informativas de sucesso/erro
  - Animação de loading durante exclusão
  
- **Melhorias de Interface**
  - Grupo de botões (Editar + Excluir) no rodapé dos cards
  - Modal responsivo com design Bootstrap
  - Cores de alerta (vermelho) para ações destrutivas
  - Feedback visual com animações suaves

- **Documentação**
  - Seção completa sobre exclusão no GUIA_DE_USO.md
  - Template alternativo delete_confirm.html
  - Instruções de backup e recuperação
  - Exemplos práticos de uso

### 🔧 Melhorado
- Animações de entrada dos cards (fadeInUp)
- Estilos CSS para botões de ação
- Responsividade dos modais
- Mensagens de feedback mais descritivas

### 🛡️ Segurança
- Confirmação obrigatória antes de excluir
- Try-catch para prevenir erros de banco
- Rollback automático em caso de falha
- Validação de existência do registro

---

## [1.1.0] - 2024-09-29 - Edição Implementada

### ✨ Adicionado
- **Funcionalidade de Edição de Miniaturas**
  - Rota `/edit_miniature/<id>`
  - Template edit_miniature.html
  - Botão "✏️ Editar" em cada card
  - Campos pré-preenchidos com dados atuais
  - Validação completa de dados
  
- **Melhorias de UX**
  - Alerta informativo mostrando qual item está sendo editado
  - Aviso sobre alterações permanentes
  - Botões claros: Salvar e Cancelar
  - Mensagens de sucesso/erro

- **Documentação**