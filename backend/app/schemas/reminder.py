from typing import List, Optional
from pydantic import BaseModel


class TaskCompletionBase(BaseModel):
    reminder_id: int
    status: str = "completed"
    completed_at: Optional[str] = None
    patient_speech_transcript: Optional[str] = None
    response_time_seconds: Optional[float] = None
    attempt_count: int = 1
    notes: Optional[str] = None


class TaskCompletionCreate(TaskCompletionBase):
    pass


class TaskCompletionResponse(TaskCompletionBase):
    id: int
    created_at: str = ""

    class Config:
        from_attributes = True


class ReminderBase(BaseModel):
    patient_id: int
    title: str
    category: str = "medicine"
    scheduled_time: str
    repeat_days: str = "daily"
    is_active: bool = True
    audio_prompt: str
    max_retries: int = 3
    retry_interval_minutes: int = 5


class ReminderCreate(ReminderBase):
    pass


class ReminderUpdate(BaseModel):
    patient_id: Optional[int] = None
    title: Optional[str] = None
    category: Optional[str] = None
    scheduled_time: Optional[str] = None
    repeat_days: Optional[str] = None
    is_active: Optional[bool] = None
    audio_prompt: Optional[str] = None
    max_retries: Optional[int] = None
    retry_interval_minutes: Optional[int] = None


class ReminderResponse(ReminderBase):
    id: int
    recent_completions: List[TaskCompletionResponse] = []
    created_at: str = ""
    updated_at: str = ""

    class Config:
        from_attributes = True


class VoiceConfirmRequest(BaseModel):
    reminder_id: int
    patient_speech: str


class ReminderCompleteRequest(BaseModel):
    status: str = "completed"
    notes: Optional[str] = "Marked as completed"
    patient_speech: Optional[str] = None
    response_time_seconds: Optional[float] = 5.0

