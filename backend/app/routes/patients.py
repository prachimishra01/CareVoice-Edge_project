from typing import List
from fastapi import APIRouter, HTTPException, status
from ..schemas.patient import PatientCreate, PatientUpdate, PatientResponse
from ..services.patient_service import PatientService

router = APIRouter(prefix="/patients", tags=["Patient Management"])


@router.get("", response_model=List[PatientResponse])
async def get_patients():
    """Retrieve all registered patients."""
    return await PatientService.get_all()


@router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient_by_id(patient_id: int):
    """Retrieve patient details by ID."""
    patient = await PatientService.get_by_id(patient_id)
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {patient_id} not found",
        )
    return patient


@router.post("", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
async def create_patient(data: PatientCreate):
    """Register a new patient."""
    return await PatientService.create(data)


@router.put("/{patient_id}", response_model=PatientResponse)
async def update_patient(patient_id: int, data: PatientUpdate):
    """Update patient information and emergency contact."""
    updated = await PatientService.update(patient_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {patient_id} not found",
        )
    return updated


@router.delete("/{patient_id}", status_code=status.HTTP_200_OK)
async def delete_patient(patient_id: int):
    """Delete a patient record."""
    success = await PatientService.delete(patient_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Patient with ID {patient_id} not found",
        )
    return {"message": f"Patient with ID {patient_id} deleted successfully"}
