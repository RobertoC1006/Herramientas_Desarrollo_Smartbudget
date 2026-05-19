from fastapi import APIRouter, Depends, HTTPException
from api.schemas.simulator import SimulationRequest, SimulationResponse
from api.dependencies import get_db, get_current_user
from core import simulator as simulator_core
from core import budgets as budgets_core
from core import goals as goals_core
from core.exceptions import PresupuestoNoEncontradoError

router = APIRouter()

@router.post("/", response_model=SimulationResponse)
def simular_compra(
    req: SimulationRequest,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    try:
        # Obtener presupuesto activo para el saldo_disponible
        budget = budgets_core.obtener_presupuesto_activo(db, user.id)
        saldo_disponible = budget.saldo_disponible
    except PresupuestoNoEncontradoError:
        saldo_disponible = 0.0

    # Obtener metas activas
    metas = goals_core.listar_metas_con_progreso(db, user.id)
    # Filtramos solo las metas en progreso o pendientes
    from core.enums import EstadoMeta
    metas_activas = [m for m in metas if m["estado"] in [EstadoMeta.PENDIENTE, EstadoMeta.EN_PROGRESO]]

    # Llamar al simulador (stateless)
    resultado = simulator_core.simular_compra(saldo_disponible, req.monto_compra, metas_activas)
    
    return resultado
