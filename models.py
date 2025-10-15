from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os

db = SQLAlchemy()

class Team(db.Model):
    __tablename__ = 'teams'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    country = db.Column(db.String(50))
    is_custom = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
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
    custom_team = db.Column(db.String(100))
    year = db.Column(db.Integer)
    scale = db.Column(db.String(20))
    photo = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f'<Miniature {self.model}>'
    
    @property
    def photo_url(self):
        """Retorna a URL da foto ou uma imagem padrão"""
        if self.photo:
            return f'/static/uploads/{self.photo}'
        return '/static/images/no-image.svg'
    
    def delete_photo(self):
        """Remove o arquivo de foto do disco"""
        if self.photo:
            photo_path = os.path.join('static/uploads', self.photo)
            if os.path.exists(photo_path):
                try:
                    os.remove(photo_path)
                    return True
                except Exception as e:
                    print(f"Erro ao remover foto: {e}")
                    return False
        return False
    #