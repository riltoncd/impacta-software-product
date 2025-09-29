// Validação de formulários Bootstrap
(function() {
    'use strict';
    window.addEventListener('load', function() {
        var forms = document.getElementsByClassName('needs-validation');
        var validation = Array.prototype.filter.call(forms, function(form) {
            form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
})();

// Controle de equipe personalizada
document.addEventListener('DOMContentLoaded', function() {
    const teamSelect = document.getElementById('team_id');
    const customTeamInput = document.getElementById('custom_team');
    
    if (teamSelect && customTeamInput) {
        // Quando seleciona uma equipe, limpa o campo personalizado
        teamSelect.addEventListener('change', function() {
            if (this.value) {
                customTeamInput.value = '';
            }
        });
        
        // Quando digita equipe personalizada, limpa a seleção
        customTeamInput.addEventListener('input', function() {
            if (this.value) {
                teamSelect.value = '';
            }
        });
    }
});

// Auto-dismiss de alertas após 5 segundos
document.addEventListener('DOMContentLoaded', function() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            if (alert.classList.contains('show')) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 5000);
    });
});

// Animação suave ao carregar cards
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.card');
    cards.forEach(function(card, index) {
        card.style.animation = `fadeInUp 0.5s ease-in-out ${index * 0.1}s both`;
    });
});

// Adicionar estilos de animação dinamicamente
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
    
    /* Efeito de loading no botão de excluir */
    .btn-danger:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }
`;
document.head.appendChild(style);