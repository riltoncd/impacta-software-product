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
//
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

// Preview de foto antes do upload
document.addEventListener('DOMContentLoaded', function() {
    const photoInput = document.getElementById('photo');
    if (photoInput) {
        photoInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            const preview = document.getElementById('photoPreview');
            
            if (file) {
                // Verificar tamanho do arquivo (16MB)
                if (file.size > 16 * 1024 * 1024) {
                    preview.innerHTML = '<div class="alert alert-danger">Arquivo muito grande! Máximo 16MB.</div>';
                    photoInput.value = '';
                    return;
                }
                
                // Verificar tipo de arquivo
                const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
                if (!validTypes.includes(file.type)) {
                    preview.innerHTML = '<div class="alert alert-danger">Formato inválido! Use PNG, JPG, JPEG, GIF ou WEBP.</div>';
                    photoInput.value = '';
                    return;
                }
                
                // Mostrar preview
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.innerHTML = `
                        <div class="card">
                            <div class="card-body text-center">
                                <p class="mb-2"><strong>Preview da foto:</strong></p>
                                <img src="${e.target.result}" class="img-fluid rounded" style="max-height: 300px;">
                                <p class="text-muted mt-2 mb-0">
                                    <small>${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB)</small>
                                </p>
                            </div>
                        </div>
                    `;
                };
                reader.readAsDataURL(file);
            } else {
                preview.innerHTML = '';
            }
        });
    }
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
    
    /* Hover nas imagens dos cards */
    .card-img-top {
        transition: transform 0.3s ease;
    }
    
    .card:hover .card-img-top {
        transform: scale(1.05);
    }
`;
document.head.appendChild(style);