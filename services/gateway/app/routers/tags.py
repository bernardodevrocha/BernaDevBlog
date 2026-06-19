from fastapi import APIRouter, Request

from app.config import settings
from app.proxy import forward
from app.security.rate_limit import limiter


router = APIRouter(prefix="/api/tags")


@router.get("")
@limiter.limit("60/minute")
async def list_tags(request: Request):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/tags")
