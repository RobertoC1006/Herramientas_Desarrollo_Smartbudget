from db.models import User
import datetime

class MockQuery:
    def __init__(self, model_class, db_session):
        self.model_class = model_class
        self.db_session = db_session
    
    def filter(self, condition):
        return self
        
    def first(self):
        if self.model_class == User:
            if getattr(self.db_session, 'last_user', None):
                return self.db_session.last_user
            return User(id=1, email="test@test.com", hashed_password="$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjIQqiRQYq")
        return None

class MockSessionLocal:
    def __init__(self):
        self.last_user = None

    def query(self, model_class):
        return MockQuery(model_class, self)
        
    def add(self, obj):
        if isinstance(obj, User):
            self.last_user = obj
            
    def commit(self):
        pass
        
    def refresh(self, obj):
        if isinstance(obj, User):
            obj.id = 1
            obj.created_at = datetime.datetime.utcnow()
            
    def close(self):
        pass

SessionLocal = MockSessionLocal
