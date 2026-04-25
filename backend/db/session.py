import datetime
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.config import settings
from db.models import Base


# ─── MODO DE OPERACIÓN ──────────────────────────────────────────────────────
# Si en el .env pones USE_MOCK_DB=True, se usará el Mock de Fabián.
# Si no está o es False, se usará la conexión real a MySQL.
USE_MOCK = os.getenv("USE_MOCK_DB", "True").lower() == "true"

if USE_MOCK:
    # ─── MOCK DE FABIÁN (Para desarrollo rápido sin BD) ───
    class MockQuery:
        def __init__(self, model_class, db_session):
            self.model_class = model_class
            self.db_session = db_session
        def filter(self, *args, **kwargs): return self
        def first(self):
            from db.models import User
            if self.model_class == User:
                return User(id=1, email="test@test.com", hashed_password="...")
            return None
        def count(self): return 0
        def all(self): return []

    class MockSessionLocal:
        def __init__(self): self.last_user = None
        def query(self, model_class): return MockQuery(model_class, self)
        def add(self, obj): pass
        def commit(self): pass
        def refresh(self, obj):
            if hasattr(obj, 'id'): obj.id = 1
        def close(self): pass

    SessionLocal = MockSessionLocal
    print("⚠️  AVISO: Usando BASE DE DATOS MOCK (Memoria temporal)")
else:
    # ─── CONEXIÓN REAL (Para Roberto y Producción) ───
    # Usamos pool_pre_ping=True para que SQLAlchemy verifique si la conexión 
    # sigue viva antes de usarla (evita errores tras periodos de inactividad).
    engine = create_engine(
        settings.DATABASE_URL, 
        pool_pre_ping=True,
        pool_recycle=3600
    )
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    print("✅ CONEXIÓN REAL: MySQL en Docker está activa")

def get_db_session():
    """
    Función de utilidad para obtener una sesión.
    En FastAPI se usa via Dependencia (Depends).
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
