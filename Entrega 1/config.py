import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-f1-miniatures'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'postgresql://f1user:f1password@localhost/f1miniatures'
    SQLALCHEMY_TRACK_MODIFICATIONS = False