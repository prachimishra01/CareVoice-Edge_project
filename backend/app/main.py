import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from .config import settings
from .database import connect_to_database, close_database_connection, is_mock
from .routes import api_v1_router

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("carevoice.main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to MongoDB and seed default records
    logger.info("Initializing CareVoice-Edge backend...")
    await connect_to_database()
    yield
    # Shutdown: Close database connections
    logger.info("Shutting down CareVoice-Edge backend...")
    await close_database_connection()


app = FastAPI(
    title="CareVoice-Edge REST API",
    description=(
        "FastAPI + MongoDB Backend for CareVoice-Edge Patient Assistant & Caretaker Dashboard. "
        "Provides patient management, repeating voice reminders, activity history, health monitoring, "
        "and emergency fall detection alerts."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Configure CORS for Flutter frontend (Web, Mobile Emulators, LAN Devices)
allowed_origins = [orig.strip() for orig in settings.CORS_ORIGINS.split(",") if orig.strip()]
if not allowed_origins or "*" in allowed_origins:
    allowed_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API v1 routes
app.include_router(api_v1_router)


@app.get("/", tags=["System"])
async def root():
    """System entry point and Swagger documentation pointer."""
    return {
        "app": "CareVoice-Edge Backend",
        "version": "1.0.0",
        "status": "online",
        "docs_url": "/docs",
        "api_v1": "/api/v1",
    }


@app.get("/health", tags=["System"])
async def health_check():
    """Health check endpoint indicating database connectivity mode."""
    from .database import is_mock

    return {
        "status": "healthy",
        "database": "mock_in_memory" if is_mock else "mongodb_connected",
        "environment": settings.ENVIRONMENT,
    }


if __name__ == "__main__":
    uvicorn.run("app.main:app", host=settings.HOST, port=settings.PORT, reload=True)
