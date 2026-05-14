"""
core/ai.py — Extracción de datos de tickets con IA (OCR)

STUB para que la API de Fabián compile.
Roberto debe implementar la lógica real con OpenAI GPT-4o.

Funciones requeridas por api/routes/expenses.py:
- extraer_gasto_desde_imagen(content_bytes, mime_type) → dict
- extraer_gasto_desde_pdf(content_bytes) → dict
"""

from core.exceptions import OCRFallidoError
from core.config import settings


async def extraer_gasto_desde_imagen(content_bytes: bytes, mime_type: str) -> dict:
    """
    Extrae datos estructurados de una imagen de ticket/boleta.
    
    Lanza OCRFallidoError si la confianza es menor a OCR_CONFIANZA_MINIMA.
    
    TODO (Roberto): Implementar con OpenAI GPT-4o Vision.
    """
    raise OCRFallidoError(
        "OCR de imágenes aún no implementado. Roberto debe conectar OpenAI GPT-4o."
    )


async def extraer_gasto_desde_pdf(content_bytes: bytes) -> dict:
    """
    Extrae datos estructurados de un PDF de ticket/boleta.
    
    Lanza OCRFallidoError si la confianza es menor a OCR_CONFIANZA_MINIMA.
    
    TODO (Roberto): Implementar con OpenAI GPT-4o.
    """
    raise OCRFallidoError(
        "OCR de PDFs aún no implementado. Roberto debe conectar OpenAI GPT-4o."
    )
