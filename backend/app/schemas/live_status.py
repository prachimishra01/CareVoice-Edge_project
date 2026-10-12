from typing import Optional
from pydantic import BaseModel


class CurrentReminderInfo(BaseModel):
    id: Optional[int] = None
    title: str = ""
    category: str = ""
    scheduled_time: str = ""


class LastConfirmationInfo(BaseModel):
    id: Optional[int] = None
    status: str = ""
    timestamp: Optional[str] = None
    transcript: Optional[str] = None


class NextReminderInfo(BaseModel):
    id: Optional[int] = None
    title: str = ""
    scheduled_time: str = ""


class DeviceStatusInfo(BaseModel):
    offline_mode: bool = True
    target: str = "edge_device"
    speech_engine: str = "piper_tts"
    system_status: str = "online"
    wakeword_active: bool = True
    raspberry_connected: bool = True


class LiveStatus(BaseModel):
    current_reminder: CurrentReminderInfo = CurrentReminderInfo()
    last_confirmation: LastConfirmationInfo = LastConfirmationInfo()
    next_reminder: NextReminderInfo = NextReminderInfo()
    device_status: DeviceStatusInfo = DeviceStatusInfo()
