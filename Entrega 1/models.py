from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class Team(db.Model):
    __tablename__ = 'teams'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    country = db.Column(db.String(50))
    is_custom = db.Column(db.Boolean, default=False)  # Para equipes não oficiais
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relacionamento com miniaturas
    miniatures = db.relationship('Miniature', backref='team_ref', lazy=True)
    
    def __repr__(self):
        return f'<Team {self.name}>'

class Miniature(db.Model):
    __tablename__ = 'miniatures'
    
    id = db.Column(db.Integer, primary_key=True)
    model = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    pilot = db.Column(db.String(100))
    team_id = db.Column(db.Integer, db.ForeignKey('teams.id'), nullable=False)
    custom_team = db.Column(db.String(100))  # Para equipes não cadastradas
    year = db.Column(db.Integer)
    scale = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<Miniature {self.model}>'