from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, UserOut
from app.security.hashing import verify_password
from app.security.jwt import create_token, decode_token
from app.security.middleware import require_internal
from app.config import settings

router = APIRouter(prefix="/auth", dependencies=[Depends(require_internal)])


@router.post("/login")
async def login(body: LoginRequest, response: Response, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_token(user.email)
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        max_age=settings.JWT_EXPIRE_MINUTES * 60,
        samesite="lax",
        secure=False,  # set True in production with HTTPS
    )
    return UserOut.model_validate(user)


@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie("access_token")
    return {"ok": True}


@router.get("/me")
async def me(request: Request, db: AsyncSession = Depends(get_db)):
    token = request.cookies.get("access_token") or _bearer_token(request)
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    email = decode_token(token)
    if not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    return UserOut.model_validate(user)


def _bearer_token(request: Request) -> str | None:
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        return auth[7:]
    return None
