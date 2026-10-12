from fastapi import APIRouter
from ..schemas.analytics import AnalyticsSummary
from ..services.analytics_service import AnalyticsService

router = APIRouter(prefix="/analytics", tags=["Analytics & Compliance"])


@router.get("", response_model=AnalyticsSummary)
async def get_analytics():
    """Get aggregated reminder adherence, task completions, and compliance analytics."""
    return await AnalyticsService.get_summary()
