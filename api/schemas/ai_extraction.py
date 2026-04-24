from pydantic import BaseModel, Field
from datetime import date
from typing import Optional
from core.enums import ExpenseCategoryEnum

class AIExtractionResponse(BaseModel):
    descripcion: str
    monto: float = Field(..., gt=0, description="Monto total del gasto extraído")
    categoria: ExpenseCategoryEnum
    fecha: date
    texto_completo: Optional[str] = Field(None, description="Texto crudo de la boleta")
