"""
db/session.py — Gestión de conexión y sesiones de base de datos

Este archivo es responsabilidad del DB Master. 
Establece el motor de conexión (Engine) y la fábrica de sesiones (SessionLocal).
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.config import settings

# 1. Crear el motor de conexión (Engine)
# Usamos pool_pre_ping=True para que SQLAlchemy verifique si la conexión 
# sigue viva antes de usarla (evita errores tras periodos de inactividad).
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600, # Reinicia conexiones cada hora
)

# 2. Fábrica de sesiones
# autocommit=False: los cambios no se guardan hasta llamar a db.commit()
# autoflush=False: no envía cambios a la BD automáticamente antes de cada query
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

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
