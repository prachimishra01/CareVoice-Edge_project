from typing import List
from fastapi import APIRouter, HTTPException, Query, status
from ..schemas.emergency import (
    EmergencyTriggerRequest,
    EmergencyResolveRequest,
    EmergencyEventResponse,
)
from ..services.emergency_service import EmergencyService

router = APIRouter(prefix="/emergency", tags=["Alerts & Emergencies"])


@router.get("", response_model=List[EmergencyEventResponse])
async def get_emergencies():
    """Get list of active and recent emergency events."""
    return await EmergencyService.get_all()


@router.post("/trigger", response_model=EmergencyEventResponse, status_code=status.HTTP_201_CREATED)
async def trigger_emergency(data: EmergencyTriggerRequest):
    """Trigger an emergency alert (e.g. fall detection, manual SOS button)."""
    return await EmergencyService.trigger(data)


@router.put("/{emergency_id}/resolve", response_model=EmergencyEventResponse)
async def resolve_emergency(emergency_id: int, data: EmergencyResolveRequest):
    """Mark an active emergency alert as resolved by caretaker."""
    updated = await EmergencyService.resolve(emergency_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Emergency event with ID {emergency_id} not found",
        )
    return updated


@router.post("/voice-sos", response_model=EmergencyEventResponse, status_code=status.HTTP_201_CREATED)
async def voice_sos(speech_transcript: str = Query("Emergency help requested by voice")):
    """Trigger emergency via voice SOS phrase recognition."""
    return await EmergencyService.voice_sos(speech_transcript=speech_transcript)
