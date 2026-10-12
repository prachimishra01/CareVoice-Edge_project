import logging
from datetime import datetime, timezone
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
import mongomock_motor

from .config import settings

logger = logging.getLogger("carevoice.database")

client: AsyncIOMotorClient = None
db: AsyncIOMotorDatabase = None
is_mock: bool = False


async def connect_to_database() -> AsyncIOMotorDatabase:
    """Connect to MongoDB with fallback to in-memory mock if server is unavailable."""
    global client, db, is_mock

    try:
        logger.info(f"Connecting to MongoDB at {settings.MONGODB_URL}...")
        real_client = AsyncIOMotorClient(
            settings.MONGODB_URL,
            serverSelectionTimeoutMS=2500,
        )
        # Verify connection
        await real_client.admin.command("ping")
        client = real_client
        db = client[settings.DATABASE_NAME]
        is_mock = False
        logger.info(f"Connected to MongoDB successfully: {settings.DATABASE_NAME}")
    except Exception as e:
        logger.warning(
            f"Could not connect to MongoDB server ({e}). Initializing in-memory mock database for fallback."
        )
        mock_client = mongomock_motor.AsyncMongoMockClient()
        client = mock_client
        db = client[settings.DATABASE_NAME]
        is_mock = True
        logger.info("In-memory MongoDB mock database is active.")

    await seed_initial_data()
    return db


async def close_database_connection():
    """Close MongoDB connection."""
    global client
    if client:
        client.close()
        logger.info("MongoDB connection closed.")


def get_db() -> AsyncIOMotorDatabase:
    """Return database handle, lazily initializing mock fallback if called before lifespan."""
    global client, db, is_mock
    if db is None:
        mock_client = mongomock_motor.AsyncMongoMockClient()
        client = mock_client
        db = client[settings.DATABASE_NAME]
        is_mock = True
    return db


async def get_next_sequence_value(sequence_name: str) -> int:
    """Auto-increment integer ID generator using a counters collection."""
    database = get_db()
    result = await database.counters.find_one_and_update(
        {"_id": sequence_name},
        {"$inc": {"sequence_value": 1}},
        upsert=True,
        return_document=True,
    )
    return result["sequence_value"]


async def seed_initial_data():
    """Seed default patient, user, reminders, activities, and health data if database is empty."""
    database = get_db()
    now_iso = datetime.now(timezone.utc).isoformat()

    # Check if patients collection has documents
    patient_count = await database.patients.count_documents({})
    if patient_count > 0:
        return

    logger.info("Database is empty. Seeding initial CareVoice data...")

    # Seed Caregiver User
    await database.users.insert_one({
        "id": 1,
        "email": "caretaker@carevoice.local",
        "full_name": "Primary Caretaker",
        "role": "caretaker",
        "is_active": True,
        "created_at": now_iso,
    })
    await database.counters.update_one(
        {"_id": "user_id"}, {"$set": {"sequence_value": 1}}, upsert=True
    )

    # Seed Patient
    await database.patients.insert_one({
        "id": 1,
        "full_name": "Eleanor Vance",
        "age": 78,
        "room_number": "302B",
        "medical_conditions": "Hypertension, Mild Cognitive Impairment, Penicillin Allergy",
        "emergency_contact": "+1 (555) 234-5678",
        "notes": "Prefers gentle vocal reminders. Hydration assistance needed twice daily.",
        "summary": "Stable vitals with moderate mobility. Routine heart medication prescribed.",
        "caretaker_id": 1,
        "created_at": now_iso,
        "updated_at": now_iso,
    })
    await database.counters.update_one(
        {"_id": "patient_id"}, {"$set": {"sequence_value": 1}}, upsert=True
    )

    # Seed Default Reminders
    reminders = [
        {
            "id": 1,
            "patient_id": 1,
            "title": "Morning Blood Pressure Meds",
            "category": "medicine",
            "scheduled_time": "09:00",
            "repeat_days": "daily",
            "is_active": True,
            "audio_prompt": "Good morning Eleanor. Please take your blood pressure tablet with a glass of water.",
            "max_retries": 3,
            "retry_interval_minutes": 5,
            "recent_completions": [
                {
                    "id": 1,
                    "reminder_id": 1,
                    "status": "completed",
                    "completed_at": now_iso,
                    "patient_speech_transcript": "Yes I have taken it",
                    "response_time_seconds": 6.8,
                    "attempt_count": 1,
                    "notes": "Spoken confirmation verified",
                    "created_at": now_iso,
                }
            ],
            "created_at": now_iso,
            "updated_at": now_iso,
        },
        {
            "id": 2,
            "patient_id": 1,
            "title": "Afternoon Hydration",
            "category": "hydration",
            "scheduled_time": "14:00",
            "repeat_days": "daily",
            "is_active": True,
            "audio_prompt": "Hi Eleanor, it is two in the afternoon. Please drink a full glass of fresh water.",
            "max_retries": 2,
            "retry_interval_minutes": 5,
            "recent_completions": [],
            "created_at": now_iso,
            "updated_at": now_iso,
        },
        {
            "id": 3,
            "patient_id": 1,
            "title": "Evening Heart Medicine",
            "category": "medicine",
            "scheduled_time": "20:00",
            "repeat_days": "daily",
            "is_active": True,
            "audio_prompt": "Time for your evening heart medication. Please take one tablet before dinner.",
            "max_retries": 3,
            "retry_interval_minutes": 5,
            "recent_completions": [],
            "created_at": now_iso,
            "updated_at": now_iso,
        },
    ]
    await database.reminders.insert_many(reminders)
    await database.counters.update_one(
        {"_id": "reminder_id"}, {"$set": {"sequence_value": 3}}, upsert=True
    )
    await database.counters.update_one(
        {"_id": "task_completion_id"}, {"$set": {"sequence_value": 1}}, upsert=True
    )

    # Seed Sample Activities
    activities = [
        {
            "id": 1,
            "patient_id": 1,
            "activity_type": "Walking",
            "status": "Normal",
            "details": "Patient walking in room 302B",
            "timestamp": "10 minutes ago",
            "created_at": now_iso,
        },
        {
            "id": 2,
            "patient_id": 1,
            "activity_type": "Sleeping",
            "status": "Normal",
            "details": "Resting peacefully in bed",
            "timestamp": "25 minutes ago",
            "created_at": now_iso,
        },
        {
            "id": 3,
            "patient_id": 1,
            "activity_type": "Sitting",
            "status": "Normal",
            "details": "Sitting in armchair reading",
            "timestamp": "40 minutes ago",
            "created_at": now_iso,
        },
        {
            "id": 4,
            "patient_id": 1,
            "activity_type": "Standing",
            "status": "Normal",
            "details": "Standing near window",
            "timestamp": "1 hour ago",
            "created_at": now_iso,
        },
        {
            "id": 5,
            "patient_id": 1,
            "activity_type": "Medicine Taken",
            "status": "Completed",
            "details": "Confirmed morning dose",
            "timestamp": "2 hours ago",
            "created_at": now_iso,
        },
        {
            "id": 6,
            "patient_id": 1,
            "activity_type": "Eating",
            "status": "Normal",
            "details": "Had breakfast",
            "timestamp": "3 hours ago",
            "created_at": now_iso,
        },
    ]
    await database.activities.insert_many(activities)
    await database.counters.update_one(
        {"_id": "activity_id"}, {"$set": {"sequence_value": 6}}, upsert=True
    )

    # Seed Sample Health Data / Vitals
    health_records = [
        {
            "id": 1,
            "patient_id": 1,
            "heart_rate": 72.0,
            "spo2": 98.0,
            "temperature": 36.6,
            "systolic_bp": 120,
            "diastolic_bp": 80,
            "status": "Normal",
            "timestamp": now_iso,
            "created_at": now_iso,
        },
        {
            "id": 2,
            "patient_id": 1,
            "heart_rate": 75.0,
            "spo2": 97.5,
            "temperature": 36.7,
            "systolic_bp": 122,
            "diastolic_bp": 81,
            "status": "Normal",
            "timestamp": now_iso,
            "created_at": now_iso,
        },
    ]
    await database.health_data.insert_many(health_records)
    await database.counters.update_one(
        {"_id": "health_data_id"}, {"$set": {"sequence_value": 2}}, upsert=True
    )

    # Initialize Emergency Counters
    await database.counters.update_one(
        {"_id": "emergency_id"}, {"$set": {"sequence_value": 0}}, upsert=True
    )

    logger.info("Initial data seeded successfully.")
