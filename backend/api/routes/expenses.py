from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from api.schemas.ai_extraction import AIExtractionResponse
from api.dependencies import get_current_user

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
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=400, 
            detail=f"Tipo de archivo no permitido: {file.content_type}. Solo se aceptan JPG, PNG y PDF."
        )
    
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"El archivo excede el tamaño máximo permitido de {MAX_FILE_SIZE_MB}MB."
        )
    
    await file.seek(0)
    
    try:
        # Aquí se conectará la lógica de IA en el futuro
        # raw_ai_data = await process_receipt_with_ai(file)
        raw_ai_data = {
            "descripcion": f"Compra extraída de {file.filename}",
            "monto": 45.50,
            "categoria": "otros", # CategoriaGasto fallback
            "fecha": "2023-10-27",
            "texto_completo": "Mock OCR"
        }
        
        validated_data = AIExtractionResponse(**raw_ai_data)
        return validated_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error procesando la boleta con IA: {str(e)}")
