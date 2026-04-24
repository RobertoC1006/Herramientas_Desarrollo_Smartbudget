import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SmartBudget+"
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    
    # Orígenes permitidos para CORS (PWA readiness)
    BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080", "http://localhost:5173", "*"]

settings = Settings()
