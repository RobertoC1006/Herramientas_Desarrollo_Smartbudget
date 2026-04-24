from fastapi import Header, HTTPException, Depends

# Esta es una dependencia de mock para proteger las rutas.
# Más adelante se implementará OAuth2PasswordBearer real.

async def get_current_user(authorization: str = Header(None)):
    """
    Dependencia de seguridad que simula la validación de un token.
    En el futuro, esto validará el JWT extraído de la cabecera (Flutter)
    o de la Cookie (PWA).
    """
    if not authorization or not authorization.startswith("Bearer "):
        # Descomentar la siguiente línea para activar la seguridad real
        # raise HTTPException(status_code=401, detail="No autenticado")
        return {"user_id": 1, "username": "test_user"}
    
    token = authorization.split(" ")[1]
    if token != "token_falso_secreto":
        raise HTTPException(status_code=401, detail="Token inválido")
        
    return {"user_id": 1, "username": "test_user"}
