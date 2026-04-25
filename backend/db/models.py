from datetime import datetime

class User:
    def __init__(self, id=1, nombre="Test User", email="test@test.com", hashed_password=""):
        self.id = id
        self.nombre = nombre
        self.email = email
        self.hashed_password = hashed_password
        self.created_at = datetime.utcnow()
