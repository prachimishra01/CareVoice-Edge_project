from typing import List, Optional
from fastapi import APIRouter, Query, status
from ..schemas.activity import ActivityCreate, ActivityResponse
from ..services.activity_service import ActivityService

router = APIRouter(prefix="/activities", tags=["Activity Management"])


@router.post("", response_model=ActivityResponse, status_code=status.HTTP_201_CREATED)
async def create_activity(data: ActivityCreate):
    """Log a new patient activity (Walking, Sitting, Standing, Lying, Fall Detected, etc.)."""
    return await ActivityService.create(data)


@router.get("", response_model=List[ActivityResponse])
async def get_activities(
    patient_id: Optional[int] = Query(None, description="Filter by patient ID"),
    limit: int = Query(50, ge=1, le=200, description="Max number of records"),
    start_date: Optional[str] = Query(None, description="Start date/time ISO string"),
    end_date: Optional[str] = Query(None, description="End date/time ISO string"),
):
    """Retrieve activity history with optional filters."""
    return await ActivityService.get_history(
        patient_id=patient_id,
        limit=limit,
        start_date=start_date,
        end_date=end_date,
    )


@router.get("/recent", response_model=List[ActivityResponse])
async def get_recent_activities(
    patient_id: Optional[int] = Query(None, description="Filter by patient ID"),
    limit: int = Query(10, ge=1, le=50, description="Number of recent records"),
):
    """Retrieve most recent activities for display on the dashboard."""
    return await ActivityService.get_recent(patient_id=patient_id, limit=limit)


@router.get("/patient/{patient_id}", response_model=List[ActivityResponse])
async def get_patient_activities(
    patient_id: int,
    limit: int = Query(50, ge=1, le=100),
):
    """Retrieve activity history for a specific patient."""
    return await ActivityService.get_history(patient_id=patient_id, limit=limit)


@router.get("/{activity_id}", response_model=ActivityResponse)
async def get_activity_by_id(activity_id: int):
    """Retrieve a specific activity record by ID."""
    from fastapi import HTTPException
    activity = await ActivityService.get_by_id(activity_id)
    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Activity with ID {activity_id} not found",
        )
    return activity


@router.delete("/{activity_id}", status_code=status.HTTP_200_OK)
async def delete_activity(activity_id: int):
    """Delete an activity record."""
    from fastapi import HTTPException
    success = await ActivityService.delete(activity_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Activity with ID {activity_id} not found",
        )
    return {"message": f"Activity with ID {activity_id} deleted successfully"}

