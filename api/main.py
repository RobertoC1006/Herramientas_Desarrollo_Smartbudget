from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import expenses
from core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="API Backend para SmartBudget+, preparado para Flutter y PWA.",
    version="1.0.0"
)

# Configuración de CORS: Clave para la compatibilidad con PWA
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS, # Orígenes permitidos (ej. la URL de tu PWA)
    allow_credentials=True,                      # Importante si en el futuro usamos Cookies (PWA)
    allow_methods=["*"],                         # Permitir todos los métodos HTTP
    allow_headers=["*"],                         # Permitir todas las cabeceras (ej. Authorization)
)

# Registrar las rutas (Endpoints)
app.include_router(expenses.router, prefix="/api/expenses", tags=["Gastos e IA"])

@app.get("/")
def read_root():
    return {"message": f"Bienvenido a la API de {settings.PROJECT_NAME}"}
