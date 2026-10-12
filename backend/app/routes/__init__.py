from fastapi import APIRouter
from .auth import router as auth_router
from .patients import router as patients_router
from .reminders import router as reminders_router
from .activities import router as activities_router
from .health_data import router as health_data_router
from .emergency import router as emergency_router
from .alerts import router as alerts_router
from .analytics import router as analytics_router
from .live_status import router as live_status_router

api_v1_router = APIRouter(prefix="/api/v1")

api_v1_router.include_router(auth_router)
api_v1_router.include_router(patients_router)
api_v1_router.include_router(reminders_router)
api_v1_router.include_router(activities_router)
api_v1_router.include_router(health_data_router)
api_v1_router.include_router(emergency_router)
api_v1_router.include_router(alerts_router)
api_v1_router.include_router(analytics_router)
api_v1_router.include_router(live_status_router)

