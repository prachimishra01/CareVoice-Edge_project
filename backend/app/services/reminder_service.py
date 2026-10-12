from datetime import datetime, timezone
from typing import List, Optional
from ..database import get_db, get_next_sequence_value
from ..schemas.reminder import ReminderCreate, ReminderUpdate


class ReminderService:
    @staticmethod
    async def get_all(patient_id: Optional[int] = None) -> List[dict]:
        db = get_db()
        query = {}
        if patient_id is not None:
            query["patient_id"] = patient_id
        cursor = db.reminders.find(query, {"_id": 0}).sort("scheduled_time", 1)
        return await cursor.to_list(length=100)

    @staticmethod
    async def get_by_id(reminder_id: int) -> Optional[dict]:
        db = get_db()
        return await db.reminders.find_one({"id": reminder_id}, {"_id": 0})

    @staticmethod
    async def create(data: ReminderCreate) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("reminder_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        doc = data.model_dump()
        doc["id"] = new_id
        doc["recent_completions"] = []
        doc["created_at"] = now_iso
        doc["updated_at"] = now_iso

        await db.reminders.insert_one(doc)
        doc.pop("_id", None)
        return doc

    @staticmethod
    async def update(reminder_id: int, data: ReminderUpdate) -> Optional[dict]:
        db = get_db()
        update_data = {k: v for k, v in data.model_dump().items() if v is not None}
        if not update_data:
            return await ReminderService.get_by_id(reminder_id)

        update_data["updated_at"] = datetime.now(timezone.utc).isoformat()
        result = await db.reminders.find_one_and_update(
            {"id": reminder_id},
            {"$set": update_data},
            return_document=True,
            projection={"_id": 0},
        )
        return result

    @staticmethod
    async def delete(reminder_id: int) -> bool:
        db = get_db()
        result = await db.reminders.delete_one({"id": reminder_id})
        return result.deleted_count > 0

    @staticmethod
    async def announce(reminder_id: int) -> dict:
        reminder = await ReminderService.get_by_id(reminder_id)
        if not reminder:
            return {"status": "not_found", "message": f"Reminder {reminder_id} not found"}
        return {
            "status": "announced",
            "reminder_id": reminder_id,
            "title": reminder["title"],
            "audio_prompt": reminder["audio_prompt"],
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    @staticmethod
    async def confirm_voice(reminder_id: int, patient_speech: str) -> dict:
        db = get_db()
        reminder = await ReminderService.get_by_id(reminder_id)
        if not reminder:
            return {"status": "not_found", "message": f"Reminder {reminder_id} not found"}

        completion_id = await get_next_sequence_value("task_completion_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        completion_doc = {
            "id": completion_id,
            "reminder_id": reminder_id,
            "status": "completed",
            "completed_at": now_iso,
            "patient_speech_transcript": patient_speech,
            "response_time_seconds": 6.5,
            "attempt_count": 1,
            "notes": "Voice confirmation recognized and confirmed",
            "created_at": now_iso,
        }

        # Store in task_completions collection
        await db.task_completions.insert_one(completion_doc.copy())

        # Also push to reminder's recent_completions array (keep latest 10)
        completion_for_embed = completion_doc.copy()
        completion_for_embed.pop("_id", None)

        await db.reminders.update_one(
            {"id": reminder_id},
            {
                "$push": {
                    "recent_completions": {
                        "$each": [completion_for_embed],
                        "$position": 0,
                        "$slice": 10,
                    }
                },
                "$set": {"updated_at": now_iso},
            },
        )

        # Also log an activity entry for this completion
        activity_id = await get_next_sequence_value("activity_id")
        await db.activities.insert_one({
            "id": activity_id,
            "patient_id": reminder.get("patient_id", 1),
            "activity_type": "Medicine Taken",
            "status": "Completed",
            "details": f"Completed reminder: {reminder['title']} (Voice: '{patient_speech}')",
            "timestamp": "Just now",
            "created_at": now_iso,
        })

        return {
            "status": "confirmed",
            "intent": "confirm",
            "reminder_id": reminder_id,
            "task_completion": completion_for_embed,
        }

    @staticmethod
    async def complete(
        reminder_id: int,
        status: str = "completed",
        notes: Optional[str] = None,
        patient_speech: Optional[str] = None,
        response_time_seconds: Optional[float] = None,
    ) -> dict:
        db = get_db()
        reminder = await ReminderService.get_by_id(reminder_id)
        if not reminder:
            return {"status": "not_found", "message": f"Reminder {reminder_id} not found"}

        completion_id = await get_next_sequence_value("task_completion_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        completion_doc = {
            "id": completion_id,
            "reminder_id": reminder_id,
            "status": status,
            "completed_at": now_iso,
            "patient_speech_transcript": patient_speech or "Manual completion recorded",
            "response_time_seconds": response_time_seconds or 5.0,
            "attempt_count": 1,
            "notes": notes or "Reminder marked as completed",
            "created_at": now_iso,
        }

        await db.task_completions.insert_one(completion_doc.copy())

        completion_for_embed = completion_doc.copy()
        completion_for_embed.pop("_id", None)

        await db.reminders.update_one(
            {"id": reminder_id},
            {
                "$push": {
                    "recent_completions": {
                        "$each": [completion_for_embed],
                        "$position": 0,
                        "$slice": 10,
                    }
                },
                "$set": {"updated_at": now_iso},
            },
        )

        activity_id = await get_next_sequence_value("activity_id")
        await db.activities.insert_one({
            "id": activity_id,
            "patient_id": reminder.get("patient_id", 1),
            "activity_type": "Medicine Taken" if reminder.get("category") == "medicine" else "Routine Task",
            "status": "Completed",
            "details": f"Completed: {reminder['title']}. {notes or ''}".strip(),
            "timestamp": "Just now",
            "created_at": now_iso,
        })

        return {
            "status": "completed",
            "reminder_id": reminder_id,
            "task_completion": completion_for_embed,
        }

