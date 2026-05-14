"""
core/expenses.py — Lógica de gestión de gastos

STUB para que la API de Fabián compile.
Roberto debe reemplazar estas funciones con la lógica real.

Funciones requeridas por api/routes/expenses.py:
- registrar_gasto(db, user_id, categoria, monto, descripcion, comercio, fecha, fuente) → Expense
- eliminar_gasto(db, user_id, expense_id) → None
- listar_gastos_mes(db, user_id, mes, año) → list[Expense]
- calcular_gastos_por_categoria(db, user_id, mes, año) → dict
"""

from datetime import date
from sqlalchemy.orm import Session
from sqlalchemy import and_, extract

from db.models import Expense
from core.enums import CategoriaGasto, FuenteGasto
from core.exceptions import PresupuestoNoEncontradoError, GastoNoEncontradoError
from core.budgets import descontar_gasto, revertir_gasto, obtener_presupuesto_activo


def registrar_gasto(
    db: Session,
    user_id: int,
    categoria: CategoriaGasto,
    monto: float,
    descripcion: str | None,
    comercio: str | None,
    fecha: date,
    fuente: FuenteGasto = FuenteGasto.MANUAL
) -> Expense:
    """
    Registra un gasto y descuenta del presupuesto activo.
    
    Lanza:
    - PresupuestoNoEncontradoError si no hay presupuesto del mes
    - SaldoInsuficienteError si el saldo no alcanza
    """
    # Descontar del presupuesto (valida saldo y presupuesto)
    descontar_gasto(db, user_id, monto)

    gasto = Expense(
        user_id=user_id,
        categoria=categoria,
        monto=monto,
        descripcion=descripcion,
        comercio=comercio,
        fecha=fecha,
        fuente=fuente
    )
    db.add(gasto)
    db.commit()
    db.refresh(gasto)
    return gasto


def eliminar_gasto(db: Session, user_id: int, expense_id: int) -> None:
    """
    Elimina un gasto y devuelve el monto al presupuesto.
    
    Lanza GastoNoEncontradoError si no existe o no pertenece al usuario.
    """
    gasto = db.query(Expense).filter(
        Expense.id == expense_id,
        Expense.user_id == user_id
    ).first()

    if not gasto:
        raise GastoNoEncontradoError("El gasto no existe o no te pertenece.")

    # Revertir el monto al presupuesto
    revertir_gasto(db, user_id, gasto.monto)

    db.delete(gasto)
    db.commit()


def listar_gastos_mes(db: Session, user_id: int, mes: int, anio: int) -> list[Expense]:
    """
    Lista todos los gastos del usuario para un mes y año específicos.
    """
    return db.query(Expense).filter(
        and_(
            Expense.user_id == user_id,
            extract('month', Expense.fecha) == mes,
            extract('year', Expense.fecha) == anio
        )
    ).order_by(Expense.fecha.desc()).all()


def calcular_gastos_por_categoria(db: Session, user_id: int, mes: int, anio: int) -> dict:
    """
    Agrupa los gastos del mes por categoría y calcula totales.
    """
    gastos = listar_gastos_mes(db, user_id, mes, anio)

    resumen = {}
    total_mes = 0.0

    for g in gastos:
        cat = g.categoria.value if hasattr(g.categoria, 'value') else str(g.categoria)
        if cat not in resumen:
            resumen[cat] = {"total": 0.0, "cantidad": 0}
        resumen[cat]["total"] += g.monto
        resumen[cat]["cantidad"] += 1
        total_mes += g.monto

    # Agregar porcentaje por categoría
    for cat in resumen:
        resumen[cat]["porcentaje"] = round(
            (resumen[cat]["total"] / total_mes * 100) if total_mes > 0 else 0, 2
        )

    return {
        "categorias": resumen,
        "total_mes": round(total_mes, 2),
        "simbolo": "S/."
    }
