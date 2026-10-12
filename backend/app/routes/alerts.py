from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, status
from ..schemas.alert import AlertCreate, AlertResponse, AlertResolve
from ..services.emergency_service import EmergencyService

router = APIRouter(prefix="/alerts", tags=["Alerts & Fall Detection"])


@router.get("", response_model=List[AlertResponse])
async def get_alerts(
    patient_id: Optional[int] = Query(None, description="Filter by patient ID"),
    status_filter: Optional[str] = Query(None, alias="status", description="Filter by status (active, resolved)"),
    limit: int = Query(50, ge=1, le=200, description="Max alerts to retrieve"),
):
    """Retrieve patient alerts (Fall alerts, Emergency alerts, manual SOS)."""
    return await EmergencyService.get_alerts(patient_id=patient_id, status=status_filter, limit=limit)


@router.get("/{alert_id}", response_model=AlertResponse)
async def get_alert_by_id(alert_id: int):
    """Retrieve a specific alert by ID."""
    alert = await EmergencyService.get_alert_by_id(alert_id)
    if not alert:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alert with ID {alert_id} not found",
        )
    return alert


@router.post("", response_model=AlertResponse, status_code=status.HTTP_201_CREATED)
async def create_alert(data: AlertCreate):
    """Trigger or log a patient alert (Fall alert, Emergency alert, etc.)."""
    return await EmergencyService.create_alert(data)


@router.put("/{alert_id}/resolve", response_model=AlertResponse)
async def resolve_alert(alert_id: int, data: AlertResolve):
    """Mark an active alert as resolved with caretaker notes."""
    updated = await EmergencyService.resolve_alert(alert_id, data.notes)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alert with ID {alert_id} not found",
        )
    return updated


@router.delete("/{alert_id}", status_code=status.HTTP_200_OK)
async def delete_alert(alert_id: int):
    """Delete an alert record."""
    success = await EmergencyService.delete_alert(alert_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alert with ID {alert_id} not found",
        )
    return {"message": f"Alert with ID {alert_id} deleted successfully"}
