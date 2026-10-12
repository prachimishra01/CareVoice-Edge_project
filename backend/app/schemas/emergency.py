from typing import Optional
from pydantic import BaseModel


class EmergencyTriggerRequest(BaseModel):
    patient_id: Optional[int] = 1
    trigger_source: str = "manual"
    speech_transcript: Optional[str] = None


class EmergencyResolveRequest(BaseModel):
    notes: Optional[str] = None


class EmergencyEventResponse(BaseModel):
    id: int
    patient_id: Optional[int] = None
    trigger_source: str
    status: str = "active"
    speech_transcript: Optional[str] = None
    notification_sent: bool = False
    phone_call_initiated: bool = False
    resolved_at: Optional[str] = None
    notes: Optional[str] = None
    created_at: str = ""

    class Config:
        from_attributes = True
