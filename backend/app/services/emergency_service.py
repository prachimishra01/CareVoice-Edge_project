from datetime import datetime, timezone
from typing import List, Optional
from ..database import get_db, get_next_sequence_value
from ..schemas.emergency import EmergencyTriggerRequest, EmergencyResolveRequest


class EmergencyService:
    @staticmethod
    async def get_all() -> List[dict]:
        db = get_db()
        cursor = db.emergency_events.find({}, {"_id": 0}).sort("id", -1)
        return await cursor.to_list(length=100)

    @staticmethod
    async def trigger(data: EmergencyTriggerRequest) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("emergency_id")
        now_iso = datetime.now(timezone.utc).isoformat()

        doc = {
            "id": new_id,
            "patient_id": data.patient_id or 1,
            "trigger_source": data.trigger_source,
            "status": "active",
            "speech_transcript": data.speech_transcript,
            "notification_sent": True,
            "phone_call_initiated": True if "call" in data.trigger_source or "fall" in data.trigger_source else False,
            "resolved_at": None,
            "notes": None,
            "created_at": now_iso,
        }

        await db.emergency_events.insert_one(doc)
        doc.pop("_id", None)

        # Also automatically log an activity entry for the alert/fall
        activity_type = "Fall Detected" if "fall" in data.trigger_source.lower() else "Emergency Alert"
        activity_id = await get_next_sequence_value("activity_id")
        await db.activities.insert_one({
            "id": activity_id,
            "patient_id": data.patient_id or 1,
            "activity_type": activity_type,
            "status": "Alert Triggered",
            "details": f"Source: {data.trigger_source}. {data.speech_transcript or ''}".strip(),
            "timestamp": "Just now",
            "created_at": now_iso,
        })

        return doc

    @staticmethod
    async def resolve(emergency_id: int, data: EmergencyResolveRequest) -> Optional[dict]:
        db = get_db()
        now_iso = datetime.now(timezone.utc).isoformat()
        result = await db.emergency_events.find_one_and_update(
            {"id": emergency_id},
            {
                "$set": {
                    "status": "resolved",
                    "resolved_at": now_iso,
                    "notes": data.notes or "Resolved by Caretaker",
                }
            },
            return_document=True,
            projection={"_id": 0},
        )
        return result

    @staticmethod
    async def voice_sos(speech_transcript: str) -> dict:
        req = EmergencyTriggerRequest(
            patient_id=1,
            trigger_source="voice_sos",
            speech_transcript=speech_transcript,
        )
        return await EmergencyService.trigger(req)

    @staticmethod
    def _doc_to_alert_response(doc: dict) -> dict:
        return {
            "id": doc.get("id"),
            "patient_id": doc.get("patient_id", 1),
            "alert_type": doc.get("alert_type") or doc.get("trigger_source", "Emergency Alert"),
            "message": doc.get("message") or doc.get("speech_transcript") or "Alert triggered",
            "details": doc.get("details") or doc.get("notes"),
            "status": doc.get("status", "active"),
            "timestamp": doc.get("timestamp") or doc.get("created_at", datetime.now(timezone.utc).isoformat()),
            "resolved_at": doc.get("resolved_at"),
            "notification_sent": doc.get("notification_sent", True),
            "phone_call_initiated": doc.get("phone_call_initiated", False),
        }

    @staticmethod
    async def get_alerts(
        patient_id: Optional[int] = None,
        status: Optional[str] = None,
        limit: int = 50,
    ) -> List[dict]:
        db = get_db()
        query = {}
        if patient_id is not None:
            query["patient_id"] = patient_id
        if status:
            query["status"] = status
        cursor = db.emergency_events.find(query, {"_id": 0}).sort("id", -1)
        items = await cursor.to_list(length=limit)
        return [EmergencyService._doc_to_alert_response(d) for d in items]

    @staticmethod
    async def create_alert(data) -> dict:
        db = get_db()
        new_id = await get_next_sequence_value("emergency_id")
        now_iso = datetime.now(timezone.utc).isoformat()
        timestamp = data.timestamp or now_iso
        phone_call = True if ("call" in data.alert_type.lower() or "fall" in data.alert_type.lower()) else False

        doc = {
            "id": new_id,
            "patient_id": data.patient_id or 1,
            "trigger_source": data.alert_type,
            "alert_type": data.alert_type,
            "status": data.status or "active",
            "speech_transcript": data.message,
            "message": data.message,
            "details": data.details,
            "notes": data.details,
            "timestamp": timestamp,
            "notification_sent": True,
            "phone_call_initiated": phone_call,
            "resolved_at": None,
            "created_at": timestamp,
        }
        await db.emergency_events.insert_one(doc)
        doc.pop("_id", None)

        activity_type = "Fall Detected" if "fall" in data.alert_type.lower() else "Emergency Alert"
        activity_id = await get_next_sequence_value("activity_id")
        await db.activities.insert_one({
            "id": activity_id,
            "patient_id": data.patient_id or 1,
            "activity_type": activity_type,
            "status": "Alert Triggered",
            "details": f"{data.alert_type}: {data.message or ''}".strip(),
            "timestamp": "Just now",
            "created_at": now_iso,
        })
        return EmergencyService._doc_to_alert_response(doc)

    @staticmethod
    async def get_alert_by_id(alert_id: int) -> Optional[dict]:
        db = get_db()
        doc = await db.emergency_events.find_one({"id": alert_id}, {"_id": 0})
        return EmergencyService._doc_to_alert_response(doc) if doc else None

    @staticmethod
    async def resolve_alert(alert_id: int, notes: Optional[str] = None) -> Optional[dict]:
        db = get_db()
        now_iso = datetime.now(timezone.utc).isoformat()
        result = await db.emergency_events.find_one_and_update(
            {"id": alert_id},
            {
                "$set": {
                    "status": "resolved",
                    "resolved_at": now_iso,
                    "notes": notes or "Resolved by Caretaker",
                    "details": notes or "Resolved by Caretaker",
                }
            },
            return_document=True,
            projection={"_id": 0},
        )
        return EmergencyService._doc_to_alert_response(result) if result else None

    @staticmethod
    async def delete_alert(alert_id: int) -> bool:
        db = get_db()
        result = await db.emergency_events.delete_one({"id": alert_id})
        return result.deleted_count > 0

