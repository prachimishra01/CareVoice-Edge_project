from typing import List
from pydantic import BaseModel


class CategoryStats(BaseModel):
    category: str
    total: int
    completed: int
    missed: int


class AnalyticsSummary(BaseModel):
    total_reminders: int = 0
    completion_rate_percentage: float = 100.0
    total_completed_tasks: int = 0
    total_missed_tasks: int = 0
    total_emergency_events: int = 0
    active_emergencies: int = 0
    average_response_time_seconds: float = 0.0
    category_breakdown: List[CategoryStats] = []
