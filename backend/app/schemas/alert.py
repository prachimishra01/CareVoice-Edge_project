from typing import Optional
from pydantic import BaseModel, Field


class AlertCreate(BaseModel):
    patient_id: Optional[int] = 1
    alert_type: str = Field(..., description="Alert type: Fall Alert, Emergency Alert, SOS Alert, etc.")
    message: Optional[str] = Field(None, description="Alert description or speech transcript")
    details: Optional[str] = Field(None, description="Detailed diagnostic or sensor message")
    status: str = Field("active", description="Status: active | resolved | acknowledged")
    timestamp: Optional[str] = None


class AlertResolve(BaseModel):
    notes: Optional[str] = Field("Resolved by Caretaker", description="Resolution notes")


class AlertResponse(BaseModel):
    id: int
    patient_id: Optional[int] = None
    alert_type: str
    message: Optional[str] = None
    details: Optional[str] = None
    status: str = "active"
    timestamp: str = ""
    resolved_at: Optional[str] = None
    notification_sent: bool = True
    phone_call_initiated: bool = False

    class Config:
        from_attributes = True
