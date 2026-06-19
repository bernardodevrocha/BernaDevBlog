from fastapi import Request, HTTPException, status

from app.config import settings


async def require_internal(request: Request) -> None:
    """Rejects any request not originating from the gateway."""
    secret = request.headers.get("X-Internal-Secret")
    if secret != settings.INTERNAL_SECRET:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
