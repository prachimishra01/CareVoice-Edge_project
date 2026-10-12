from fastapi import APIRouter
from ..schemas.live_status import LiveStatus
from ..services.live_status_service import LiveStatusService

router = APIRouter(prefix="/live-status", tags=["Live Edge Device Status"])


@router.get("", response_model=LiveStatus)
async def get_live_status():
    """Get live device monitoring, current active reminder, and edge status."""
    return await LiveStatusService.get_status()
