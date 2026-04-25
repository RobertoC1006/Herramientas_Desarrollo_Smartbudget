from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from db.session import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relaciones
    presupuestos = relationship("Budget", back_populates="usuario")
    metas = relationship("Goal", back_populates="usuario")
    gastos = relationship("Expense", back_populates="usuario")

class Budget(Base):
    __tablename__ = "budgets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    mes = Column(Integer, nullable=False) # 1-12
    anio = Column(Integer, nullable=False)
    monto_total = Column(Float, default=0.0)
    saldo_disponible = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    usuario = relationship("User", back_populates="presupuestos")
    ingresos = relationship("IncomeLog", back_populates="presupuesto")

class IncomeLog(Base):
    __tablename__ = "income_logs"

    id = Column(Integer, primary_key=True, index=True)
    budget_id = Column(Integer, ForeignKey("budgets.id"))
    monto = Column(Float, nullable=False)
    descripcion = Column(String(255))
    fecha = Column(DateTime, default=datetime.utcnow)

    presupuesto = relationship("Budget", back_populates="ingresos")

class Goal(Base):
    __tablename__ = "goals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    nombre = Column(String(100), nullable=False)
    monto_objetivo = Column(Float, nullable=False)
    monto_actual = Column(Float, default=0.0)
    fecha_limite = Column(DateTime)
    prioridad = Column(Integer, default=1) # 1: Alta, 2: Media, 3: Baja
    created_at = Column(DateTime, default=datetime.utcnow)

    usuario = relationship("User", back_populates="metas")

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    monto = Column(Float, nullable=False)
    categoria = Column(String(50)) # Comida, Transporte, etc.
    descripcion = Column(Text)
    fecha = Column(DateTime, default=datetime.utcnow)
    es_ia_generado = Column(Boolean, default=False)

    usuario = relationship("User", back_populates="gastos")
