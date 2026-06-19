from fastapi import HTTPException, Request, status
from jose import JWTError, jwt

from app.config import settings


def _extract_token(request: Request) -> str | None:
    cookie = request.cookies.get("access_token")
    if cookie:
        return cookie
    auth = request.headers.get("Authorization", "")
    if auth.startswith("Bearer "):
        return auth[7:]
    return None


def get_user_email(request: Request) -> str | None:
    token = _extract_token(request)
    if not token:
        return None
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        return payload.get("sub")
    except JWTError:
        return None


def require_user_email(request: Request) -> str:
    email = get_user_email(request)
    if not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required")
    return email
