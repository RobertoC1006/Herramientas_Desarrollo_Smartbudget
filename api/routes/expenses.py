from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from api.schemas.ai_extraction import AIExtractionResponse
from api.dependencies import get_current_user
from core.ai import process_receipt_with_ai

router = APIRouter()

MAX_FILE_SIZE_MB = 5
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024
ALLOWED_CONTENT_TYPES = ["image/jpeg", "image/png", "application/pdf"]

@router.post("/ocr", response_model=AIExtractionResponse)
async def extract_expense_from_receipt(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user)
):
    """
    Recibe la imagen de una boleta, la valida y la envía al agente IA 
    para extraer la información estructurada.
    """
    # 1. Validación de Tipo de Archivo
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=400, 
            detail=f"Tipo de archivo no permitido: {file.content_type}. Solo se aceptan JPG, PNG y PDF."
        )
    
    # 2. Validación de Tamaño
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"El archivo excede el tamaño máximo permitido de {MAX_FILE_SIZE_MB}MB."
        )
    
    # Reseteamos el cursor del archivo después de leerlo para que la IA pueda leerlo también
    await file.seek(0)
    
    # 3. Llamada al Cerebro (Core)
    try:
        # Aquí le pasamos el control a Roberto (core/ai.py)
        raw_ai_data = await process_receipt_with_ai(file)
        
        # 4. Validar que la respuesta de OpenAI cumpla con nuestro esquema Pydantic
        validated_data = AIExtractionResponse(**raw_ai_data)
        return validated_data
        
    except Exception as e:
        # Capturamos errores de la IA (timeouts, mal formato devuelto, etc)
        raise HTTPException(status_code=500, detail=f"Error procesando la boleta con IA: {str(e)}")
