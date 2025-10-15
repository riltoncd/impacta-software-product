from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from werkzeug.utils import secure_filename
from models import db, Team, Miniature
from config import Config
import os
from datetime import datetime

app = Flask(__name__)
app.config.from_object(Config)

# Inicializar banco de dados
db.init_app(app)

def allowed_file(filename):
    """Verifica se a extensão do arquivo é permitida"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

def save_uploaded_file(file):
    """Salva arquivo de upload e retorna o nome único"""
    if file and allowed_file(file.filename):
        # Criar pasta de uploads se não existir
        upload_folder = app.config['UPLOAD_FOLDER']
        os.makedirs(upload_folder, exist_ok=True)
        
        # Criar nome único com timestamp
        filename = secure_filename(file.filename)
        name, ext = os.path.splitext(filename)
        unique_filename = f"{name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}{ext}"
        
        filepath = os.path.join(upload_folder, unique_filename)
        file.save(filepath)
        return unique_filename
    return None

@app.route('/')
def index():
    miniatures = Miniature.query.order_by(Miniature.created_at.desc()).all()
    teams = Team.query.all()
    return render_template('index.html', miniatures=miniatures, teams=teams)

@app.route('/add_miniature', methods=['GET', 'POST'])
def add_miniature():
    if request.method == 'POST':
        model = request.form['model']
        description = request.form['description']
        pilot = request.form['pilot']
        team_id = request.form.get('team_id')
        custom_team = request.form.get('custom_team')
        year = request.form.get('year')
        scale = request.form.get('scale')
        
        # Processar upload de foto
        photo_filename = None
        if 'photo' in request.files:
            file = request.files['photo']
            if file.filename:  # Se um arquivo foi selecionado
                photo_filename = save_uploaded_file(file)
                if not photo_filename:
                    flash('Formato de arquivo não permitido! Use: PNG, JPG, JPEG, GIF ou WEBP', 'error')
                    teams = Team.query.order_by(Team.name).all()
                    return render_template('add_miniature.html', teams=teams)
        
        # Validação básica
        if not model:
            flash('Modelo é obrigatório!', 'error')
            return redirect(url_for('add_miniature'))
        
        # Se não selecionou uma equipe e não informou equipe customizada
        if not team_id and not custom_team:
            flash('Selecione uma equipe ou informe uma equipe personalizada!', 'error')
            return redirect(url_for('add_miniature'))
        
        # Se informou equipe customizada, criar uma nova equipe
        if custom_team and not team_id:
            existing_team = Team.query.filter_by(name=custom_team).first()
            if not existing_team:
                new_team = Team(name=custom_team, is_custom=True)
                db.session.add(new_team)
                db.session.flush()  # Para obter o ID
                team_id = new_team.id
            else:
                team_id = existing_team.id
        
        # Criar nova miniatura
        miniature = Miniature(
            model=model,
            description=description,
            pilot=pilot,
            team_id=int(team_id) if team_id else None,
            year=int(year) if year else None,
            scale=scale,
            photo=photo_filename
        )
        
        db.session.add(miniature)
        db.session.commit()
        
        flash('Miniatura adicionada com sucesso!', 'success')
        return redirect(url_for('index'))
    
    teams = Team.query.order_by(Team.name).all()
    return render_template('add_miniature.html', teams=teams)

@app.route('/edit_miniature/<int:id>', methods=['GET', 'POST'])
def edit_miniature(id):
    miniature = Miniature.query.get_or_404(id)
    
    if request.method == 'POST':
        model = request.form['model']
        description = request.form['description']
        pilot = request.form['pilot']
        team_id = request.form.get('team_id')
        custom_team = request.form.get('custom_team')
        year = request.form.get('year')
        scale = request.form.get('scale')
        
        # Processar upload de nova foto
        if 'photo' in request.files:
            file = request.files['photo']
            if file.filename:  # Se um novo arquivo foi selecionado
                # Remover foto antiga se existir
                if miniature.photo:
                    miniature.delete_photo()
                
                # Salvar nova foto
                photo_filename = save_uploaded_file(file)
                if photo_filename:
                    miniature.photo = photo_filename
                else:
                    flash('Formato de arquivo não permitido! Use: PNG, JPG, JPEG, GIF ou WEBP', 'error')
                    teams = Team.query.order_by(Team.name).all()
                    return render_template('edit_miniature.html', miniature=miniature, teams=teams)
        
        # Validação básica
        if not model:
            flash('Modelo é obrigatório!', 'error')
            return redirect(url_for('edit_miniature', id=id))
        
        # Se não selecionou uma equipe e não informou equipe customizada
        if not team_id and not custom_team:
            flash('Selecione uma equipe ou informe uma equipe personalizada!', 'error')
            return redirect(url_for('edit_miniature', id=id))
        
        # Se informou equipe customizada, criar uma nova equipe
        if custom_team and not team_id:
            existing_team = Team.query.filter_by(name=custom_team).first()
            if not existing_team:
                new_team = Team(name=custom_team, is_custom=True)
                db.session.add(new_team)
                db.session.flush()
                team_id = new_team.id
            else:
                team_id = existing_team.id
        
        # Atualizar miniatura
        miniature.model = model
        miniature.description = description
        miniature.pilot = pilot
        miniature.team_id = int(team_id) if team_id else None
        miniature.year = int(year) if year else None
        miniature.scale = scale
        
        db.session.commit()
        
        flash('Miniatura atualizada com sucesso!', 'success')
        return redirect(url_for('index'))
    
    teams = Team.query.order_by(Team.name).all()
    return render_template('edit_miniature.html', miniature=miniature, teams=teams)

@app.route('/delete_miniature/<int:id>', methods=['POST'])
def delete_miniature(id):
    miniature = Miniature.query.get_or_404(id)
    model_name = miniature.model  # Guardar para mensagem
    
    try:
        # Remover foto se existir
        if miniature.photo:
            miniature.delete_photo()
        
        db.session.delete(miniature)
        db.session.commit()
        flash(f'Miniatura "{model_name}" excluída com sucesso!', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Erro ao excluir miniatura: {str(e)}', 'error')
    
    return redirect(url_for('index'))

@app.route('/delete_photo/<int:id>', methods=['POST'])
def delete_photo(id):
    """Remove apenas a foto da miniatura, mantendo os outros dados"""
    miniature = Miniature.query.get_or_404(id)
    
    try:
        if miniature.photo:
            miniature.delete_photo()
            miniature.photo = None
            db.session.commit()
            flash('Foto removida com sucesso!', 'success')
        else:
            flash('Esta miniatura não possui foto!', 'info')
    except Exception as e:
        db.session.rollback()
        flash(f'Erro ao remover foto: {str(e)}', 'error')
    
    return redirect(url_for('edit_miniature', id=id))

@app.route('/add_team', methods=['GET', 'POST'])
def add_team():
    if request.method == 'POST':
        name = request.form['name']
        country = request.form.get('country')
        
        if not name:
            flash('Nome da equipe é obrigatório!', 'error')
            return redirect(url_for('add_team'))
        
        # Verificar se equipe já existe
        existing_team = Team.query.filter_by(name=name).first()
        if existing_team:
            flash('Equipe já existe!', 'error')
            return redirect(url_for('add_team'))
        
        team = Team(name=name, country=country)
        db.session.add(team)
        db.session.commit()
        
        flash('Equipe adicionada com sucesso!', 'success')
        return redirect(url_for('index'))
    
    return render_template('add_team.html')

@app.route('/api/teams')
def api_teams():
    teams = Team.query.all()
    return jsonify([{'id': t.id, 'name': t.name, 'country': t.country} for t in teams])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)