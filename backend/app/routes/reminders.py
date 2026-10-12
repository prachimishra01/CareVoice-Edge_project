from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query, status
from ..schemas.reminder import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
    VoiceConfirmRequest,
    ReminderCompleteRequest,
)
from ..services.reminder_service import ReminderService

router = APIRouter(prefix="/reminders", tags=["Reminder Management"])


@router.get("", response_model=List[ReminderResponse])
async def get_reminders(patient_id: Optional[int] = Query(None, description="Optional patient filter")):
    """Get all reminders or filter by patient_id."""
    return await ReminderService.get_all(patient_id=patient_id)


@router.get("/{reminder_id}", response_model=ReminderResponse)
async def get_reminder_by_id(reminder_id: int):
    """Get a single reminder by ID."""
    reminder = await ReminderService.get_by_id(reminder_id)
    if not reminder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {reminder_id} not found",
        )
    return reminder


@router.post("", response_model=ReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(data: ReminderCreate):
    """Create a new routine reminder."""
    return await ReminderService.create(data)


@router.put("/{reminder_id}", response_model=ReminderResponse)
async def update_reminder(reminder_id: int, data: ReminderUpdate):
    """Update a reminder (e.g. toggle active or edit schedule)."""
    updated = await ReminderService.update(reminder_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {reminder_id} not found",
        )
    return updated


@router.delete("/{reminder_id}", status_code=status.HTTP_200_OK)
async def delete_reminder(reminder_id: int):
    """Delete a reminder by ID."""
    success = await ReminderService.delete(reminder_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {reminder_id} not found",
        )
    return {"message": f"Reminder with ID {reminder_id} deleted successfully"}


@router.post("/{reminder_id}/announce")
async def announce_reminder(reminder_id: int):
    """Trigger voice announcement for a specific reminder."""
    result = await ReminderService.announce(reminder_id)
    if result.get("status") == "not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {reminder_id} not found",
        )
    return result


@router.post("/confirm-voice")
async def confirm_voice(request: VoiceConfirmRequest):
    """Record spoken confirmation for a reminder and mark as completed."""
    result = await ReminderService.confirm_voice(
        reminder_id=request.reminder_id,
        patient_speech=request.patient_speech,
    )
    if result.get("status") == "not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {request.reminder_id} not found",
        )
    return result


@router.post("/{reminder_id}/complete")
async def complete_reminder(reminder_id: int, request: Optional[ReminderCompleteRequest] = None):
    """Mark a reminder as completed directly with optional notes or speech transcript."""
    req = request or ReminderCompleteRequest()
    result = await ReminderService.complete(
        reminder_id=reminder_id,
        status=req.status,
        notes=req.notes,
        patient_speech=req.patient_speech,
        response_time_seconds=req.response_time_seconds,
    )
    if result.get("status") == "not_found":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reminder with ID {reminder_id} not found",
        )
    return result

