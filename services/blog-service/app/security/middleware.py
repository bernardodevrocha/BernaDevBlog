from fastapi import Depends, HTTPException, Request, status

from app.config import settings


async def require_internal(request: Request) -> None:
    """All requests must come through the gateway."""
    if request.headers.get("X-Internal-Secret") != settings.INTERNAL_SECRET:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")


async def require_auth(request: Request) -> str:
    """Extracts the authenticated user email injected by the gateway."""
    email = request.headers.get("X-User-Email")
    if not email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required")
    return email
