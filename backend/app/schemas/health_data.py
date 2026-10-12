from typing import Optional
from pydantic import BaseModel


class HealthDataBase(BaseModel):
    patient_id: int = 1
    heart_rate: Optional[float] = None
    spo2: Optional[float] = None
    temperature: Optional[float] = None
    systolic_bp: Optional[int] = None
    diastolic_bp: Optional[int] = None
    status: str = "Normal"
    timestamp: Optional[str] = None


class HealthDataCreate(HealthDataBase):
    pass


class HealthDataResponse(HealthDataBase):
    id: int
    created_at: str = ""

    class Config:
        from_attributes = True
