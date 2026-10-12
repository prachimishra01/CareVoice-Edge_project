from datetime import datetime, timezone
from typing import List, Optional
from ..database import get_db, get_next_sequence_value
from ..schemas.health_data import HealthDataCreate


class HealthDataService:
    @staticmethod
    async def create(data: HealthDataCreate) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("health_data_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        doc = data.model_dump()
        doc["id"] = new_id
        if not doc.get("timestamp"):
            doc["timestamp"] = now_iso
        doc["created_at"] = now_iso

        await db.health_data.insert_one(doc)
        doc.pop("_id", None)
        return doc

    @staticmethod
    async def get_history(
        patient_id: Optional[int] = None,
        limit: int = 50,
    ) -> List[dict]:
        db = get_db()
        query = {}
        if patient_id is not None:
            query["patient_id"] = patient_id
        cursor = db.health_data.find(query, {"_id": 0}).sort("id", -1).limit(limit)
        return await cursor.to_list(length=limit)

    @staticmethod
    async def get_latest(patient_id: Optional[int] = None) -> Optional[dict]:
        db = get_db()
        query = {}
        if patient_id is not None:
            query["patient_id"] = patient_id
        return await db.health_data.find_one(query, {"_id": 0}, sort=[("id", -1)])

    @staticmethod
    async def get_by_id(record_id: int) -> Optional[dict]:
        db = get_db()
        return await db.health_data.find_one({"id": record_id}, {"_id": 0})

    @staticmethod
    async def delete(record_id: int) -> bool:
        db = get_db()
        result = await db.health_data.delete_one({"id": record_id})
        return result.deleted_count > 0

