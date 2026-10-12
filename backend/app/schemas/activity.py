from typing import Optional
from pydantic import BaseModel


class ActivityBase(BaseModel):
    patient_id: int = 1
    activity_type: str  # e.g., Walking, Sitting, Standing, Lying, Fall Detected
    status: str = "Normal"
    details: Optional[str] = None
    timestamp: Optional[str] = None


class ActivityCreate(ActivityBase):
    pass


class ActivityResponse(ActivityBase):
    id: int
    created_at: str = ""

    class Config:
        from_attributes = True
