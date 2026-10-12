from ..database import get_db
from ..schemas.live_status import (
    LiveStatus,
    CurrentReminderInfo,
    LastConfirmationInfo,
    NextReminderInfo,
    DeviceStatusInfo,
)


class LiveStatusService:
    @staticmethod
    async def get_status() -> LiveStatus:
        db = get_db()

        # Find first active reminder as current/next
        reminders = await db.reminders.find({"is_active": True}, {"_id": 0}).sort("scheduled_time", 1).to_list(length=10)

        current_rem = CurrentReminderInfo()
        next_rem = NextReminderInfo()

        if reminders:
            first = reminders[0]
            current_rem = CurrentReminderInfo(
                id=first.get("id"),
                title=first.get("title", ""),
                category=first.get("category", ""),
                scheduled_time=first.get("scheduled_time", ""),
            )
            if len(reminders) > 1:
                second = reminders[1]
                next_rem = NextReminderInfo(
                    id=second.get("id"),
                    title=second.get("title", ""),
                    scheduled_time=second.get("scheduled_time", ""),
                )
            else:
                next_rem = NextReminderInfo(
                    id=first.get("id"),
                    title=first.get("title", ""),
                    scheduled_time=first.get("scheduled_time", ""),
                )

        # Last confirmation
        last_comp = await db.task_completions.find_one(
            {}, {"_id": 0}, sort=[("id", -1)]
        )
        last_confirm = LastConfirmationInfo()
        if last_comp:
            last_confirm = LastConfirmationInfo(
                id=last_comp.get("id"),
                status=last_comp.get("status", ""),
                timestamp=last_comp.get("completed_at"),
                transcript=last_comp.get("patient_speech_transcript"),
            )

        device_stat = DeviceStatusInfo(
            offline_mode=True,
            target="edge_device",
            speech_engine="piper_tts",
            system_status="online",
            wakeword_active=True,
            raspberry_connected=True,
        )

        return LiveStatus(
            current_reminder=current_rem,
            last_confirmation=last_confirm,
            next_reminder=next_rem,
            device_status=device_stat,
        )
