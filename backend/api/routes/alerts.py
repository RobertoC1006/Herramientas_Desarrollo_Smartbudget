from fastapi import APIRouter, Depends, HTTPException
from typing import List
from api.schemas.alerts import AlertResponse
from api.dependencies import get_db, get_current_user
from core import smart_alerts as alerts_core

router = APIRouter()

@router.get("/", response_model=List[AlertResponse])
def listar_alertas(
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    """
    Obtiene las alertas del usuario ordenadas por prioridad:
    CRITICA (1) -> ADVERTENCIA (2) -> INFORMATIVA (3) -> MOTIVACIONAL (4)
    """
    return alerts_core.obtener_alertas_priorizadas(db, user.id)

@router.post("/generate", response_model=dict)
def generar_alertas(
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    """
    Fuerza la evaluación de las reglas financieras para generar nuevas alertas.
    Ideal para usar en un cronjob o cuando el usuario entra a la app.
    """
    alerts_core.generar_alertas_usuario(db, user.id)
    return {"message": "Reglas de alertas evaluadas exitosamente."}
