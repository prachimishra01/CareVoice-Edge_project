from typing import Optional
from pydantic import BaseModel


class PatientBase(BaseModel):
    full_name: str
    age: int
    room_number: Optional[str] = None
    medical_conditions: Optional[str] = None
    emergency_contact: Optional[str] = None
    notes: Optional[str] = None
    summary: Optional[str] = None
    caretaker_id: Optional[int] = 1


class PatientCreate(PatientBase):
    pass


class PatientUpdate(BaseModel):
    full_name: Optional[str] = None
    age: Optional[int] = None
    room_number: Optional[str] = None
    medical_conditions: Optional[str] = None
    emergency_contact: Optional[str] = None
    notes: Optional[str] = None
    summary: Optional[str] = None
    caretaker_id: Optional[int] = None


class PatientResponse(PatientBase):
    id: int
    created_at: str = ""
    updated_at: str = ""

    class Config:
        from_attributes = True
