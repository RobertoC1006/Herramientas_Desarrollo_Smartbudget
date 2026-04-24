from enum import Enum

class ExpenseCategoryEnum(str, Enum):
    COMIDA = "comida"
    TRANSPORTE = "transporte"
    SERVICIOS = "servicios"
    OCIO = "ocio"
    OTROS = "otros"
