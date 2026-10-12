from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, status
from ..schemas.health_data import HealthDataCreate, HealthDataResponse
from ..services.health_data_service import HealthDataService

router = APIRouter(prefix="/health-data", tags=["Health & Vitals Data"])


@router.post("", response_model=HealthDataResponse, status_code=status.HTTP_201_CREATED)
async def create_health_data(data: HealthDataCreate):
    """Store patient health monitoring vitals (heart rate, SpO2, temperature, blood pressure)."""
    return await HealthDataService.create(data)


@router.get("", response_model=List[HealthDataResponse])
async def get_health_data_history(
    patient_id: Optional[int] = Query(None, description="Filter by patient ID"),
    limit: int = Query(50, ge=1, le=200, description="Max records to retrieve"),
):
    """Retrieve historical health records."""
    return await HealthDataService.get_history(patient_id=patient_id, limit=limit)


@router.get("/latest", response_model=HealthDataResponse)
async def get_latest_health_data(
    patient_id: Optional[int] = Query(None, description="Filter by patient ID"),
):
    """Retrieve the most recent health metrics record."""
    latest = await HealthDataService.get_latest(patient_id=patient_id)
    if not latest:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No health vitals records found",
        )
    return latest


@router.get("/{record_id}", response_model=HealthDataResponse)
async def get_health_data_by_id(record_id: int):
    """Retrieve a specific health metrics record by ID."""
    record = await HealthDataService.get_by_id(record_id)
    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Health data record with ID {record_id} not found",
        )
    return record


@router.delete("/{record_id}", status_code=status.HTTP_200_OK)
async def delete_health_data(record_id: int):
    """Delete a health data record."""
    success = await HealthDataService.delete(record_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Health data record with ID {record_id} not found",
        )
    return {"message": f"Health data record with ID {record_id} deleted successfully"}

