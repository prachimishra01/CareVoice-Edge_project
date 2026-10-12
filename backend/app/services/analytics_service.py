from ..database import get_db
from ..schemas.analytics import AnalyticsSummary, CategoryStats


class AnalyticsService:
    @staticmethod
    async def get_summary() -> AnalyticsSummary:
        db = get_db()

        total_reminders = await db.reminders.count_documents({})
        total_completed = await db.task_completions.count_documents({"status": "completed"})
        total_missed = await db.task_completions.count_documents({"status": "missed"})

        total_tasks = total_completed + total_missed
        completion_rate = (
            round((total_completed / total_tasks) * 100, 1) if total_tasks > 0 else 100.0
        )

        total_emergencies = await db.emergency_events.count_documents({})
        active_emergencies = await db.emergency_events.count_documents({"status": "active"})

        # Response time calculation
        completions_cursor = db.task_completions.find({"response_time_seconds": {"$ne": None}})
        completions = await completions_cursor.to_list(length=100)
        if completions:
            avg_resp = sum(c.get("response_time_seconds", 0) for c in completions) / len(completions)
        else:
            avg_resp = 6.5

        # Category Breakdown
        categories = ["medicine", "exercise", "hydration", "vitals", "general"]
        breakdown = []
        for cat in categories:
            cat_reminders = await db.reminders.find({"category": cat}).to_list(length=100)
            cat_reminder_ids = [r["id"] for r in cat_reminders]
            cat_total = len(cat_reminder_ids)

            if cat_reminder_ids:
                cat_completed = await db.task_completions.count_documents(
                    {"reminder_id": {"$in": cat_reminder_ids}, "status": "completed"}
                )
                cat_missed = await db.task_completions.count_documents(
                    {"reminder_id": {"$in": cat_reminder_ids}, "status": "missed"}
                )
            else:
                cat_completed = 0
                cat_missed = 0

            breakdown.append(
                CategoryStats(
                    category=cat,
                    total=cat_total,
                    completed=cat_completed,
                    missed=cat_missed,
                )
            )

        return AnalyticsSummary(
            total_reminders=total_reminders,
            completion_rate_percentage=completion_rate,
            total_completed_tasks=total_completed,
            total_missed_tasks=total_missed,
            total_emergency_events=total_emergencies,
            active_emergencies=active_emergencies,
            average_response_time_seconds=round(avg_resp, 1),
            category_breakdown=breakdown,
        )
