from typing import Optional
from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    email: str
    full_name: str
    role: str = "caretaker"
    is_active: bool = True


class UserCreate(UserBase):
    pass


class UserResponse(UserBase):
    id: int

    class Config:
        from_attributes = True
