from datetime import datetime, timezone
from typing import List, Optional
from ..database import get_db, get_next_sequence_value
from ..schemas.patient import PatientCreate, PatientUpdate, PatientResponse


class PatientService:
    @staticmethod
    async def get_all() -> List[dict]:
        db = get_db()
        cursor = db.patients.find({}, {"_id": 0})
        return await cursor.to_list(length=100)

    @staticmethod
    async def get_by_id(patient_id: int) -> Optional[dict]:
        db = get_db()
        return await db.patients.find_one({"id": patient_id}, {"_id": 0})

    @staticmethod
    async def create(data: PatientCreate) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("patient_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        doc = data.model_dump()
        doc["id"] = new_id
        doc["created_at"] = now_iso
        doc["updated_at"] = now_iso

        await db.patients.insert_one(doc)
        doc.pop("_id", None)
        return doc

    @staticmethod
    async def update(patient_id: int, data: PatientUpdate) -> Optional[dict]:
        db = get_db()
        update_data = {k: v for k, v in data.model_dump().items() if v is not None}
        if not update_data:
            return await PatientService.get_by_id(patient_id)

        update_data["updated_at"] = datetime.now(timezone.utc).isoformat()
        result = await db.patients.find_one_and_update(
            {"id": patient_id},
            {"$set": update_data},
            return_document=True,
            projection={"_id": 0},
        )
        return result

    @staticmethod
    async def delete(patient_id: int) -> bool:
        db = get_db()
        result = await db.patients.delete_one({"id": patient_id})
        return result.deleted_count > 0
