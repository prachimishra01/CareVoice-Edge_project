from fastapi import APIRouter
from ..database import get_db
from ..schemas.user import UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication & User"])


@router.get("/me", response_model=UserResponse)
async def get_current_user():
    """Return currently active Caretaker user profile."""
    db = get_db()
    user = await db.users.find_one({"is_active": True}, {"_id": 0})
    if not user:
        return UserResponse(
            id=1,
            email="caretaker@carevoice.local",
            full_name="Primary Caretaker",
            role="caretaker",
            is_active=True,
        )
    return user
