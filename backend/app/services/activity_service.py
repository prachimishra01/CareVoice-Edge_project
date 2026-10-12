from datetime import datetime, timezone
from typing import List, Optional
from ..database import get_db, get_next_sequence_value
from ..schemas.activity import ActivityCreate


class ActivityService:
    @staticmethod
    async def create(data: ActivityCreate) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("activity_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        doc = data.model_dump()
        doc["id"] = new_id
        if not doc.get("timestamp"):
            doc["timestamp"] = "Just now"
        doc["created_at"] = now_iso

        await db.activities.insert_one(doc)
        doc.pop("_id", None)
        return doc

    @staticmethod
    async def get_history(
        patient_id: Optional[int] = None,
        limit: int = 50,
        start_date: Optional[str] = None,
        end_date: Optional[str] = None,
    ) -> List[dict]:
        db = get_db()
        query = {}
        if patient_id is not None:
            query["patient_id"] = patient_id
        if start_date or end_date:
            date_filter = {}
            if start_date:
                date_filter["$gte"] = start_date
            if end_date:
                date_filter["$lte"] = end_date
            query["created_at"] = date_filter

        cursor = db.activities.find(query, {"_id": 0}).sort("id", -1).limit(limit)
        return await cursor.to_list(length=limit)

    @staticmethod
    async def get_recent(patient_id: Optional[int] = None, limit: int = 10) -> List[dict]:
        return await ActivityService.get_history(patient_id=patient_id, limit=limit)

    @staticmethod
    async def get_by_id(activity_id: int) -> Optional[dict]:
        db = get_db()
        return await db.activities.find_one({"id": activity_id}, {"_id": 0})

    @staticmethod
    async def delete(activity_id: int) -> bool:
        db = get_db()
        result = await db.activities.delete_one({"id": activity_id})
        return result.deleted_count > 0
