from app import app
from models import db, Team

def init_database():
    with app.app_context():
        # Criar todas as tabelas
        db.create_all()
        
        # Adicionar equipes básicas de F1 (2023/2024)
        default_teams = [
            {'name': 'Red Bull Racing', 'country': 'Austria'},
            {'name': 'Mercedes-AMG Petronas', 'country': 'Germany'},
            {'name': 'Scuderia Ferrari', 'country': 'Italy'},
            {'name': 'McLaren Racing', 'country': 'United Kingdom'},
            {'name': 'Aston Martin', 'country': 'United Kingdom'},
            {'name': 'Alpine F1 Team', 'country': 'France'},
            {'name': 'Williams Racing', 'country': 'United Kingdom'},
            {'name': 'MoneyGram Haas F1', 'country': 'United States'},
            {'name': 'Visa RB F1 Team', 'country': 'Italy'},
            {'name': 'Kick Sauber', 'country': 'Switzerland'},
        ]
        
        for team_data in default_teams:
            if not Team.query.filter_by(name=team_data['name']).first():
                team = Team(name=team_data['name'], country=team_data['country'])
                db.session.add(team)
        
        db.session.commit()
        print("Banco de dados inicializado com sucesso!")
#
if __name__ == '__main__':
    init_database()