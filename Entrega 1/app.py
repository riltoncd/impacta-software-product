from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from models import db, Team, Miniature
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

# Inicializar banco de dados
db.init_app(app)

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
            scale=scale
        )
        
        db.session.add(miniature)
        db.session.commit()
        
        flash('Miniatura adicionada com sucesso!', 'success')
        return redirect(url_for('index'))
    
    teams = Team.query.order_by(Team.name).all()
    return render_template('add_miniature.html', teams=teams)

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