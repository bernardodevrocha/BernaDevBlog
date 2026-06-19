from fastapi import APIRouter, Depends, Request

from app.config import settings
from app.proxy import forward
from app.security.jwt_guard import require_user_email
from app.security.rate_limit import limiter


router = APIRouter(prefix="/api/certificates")


@router.get("")
@limiter.limit("60/minute")
async def list_certificates(request: Request):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/certificates")


@router.get("/file/{filename}")
@limiter.limit("60/minute")
async def get_certificate_file(filename: str, request: Request):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/certificates/file/{filename}")


@router.post("")
@limiter.limit("20/minute")
async def create_certificate(request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/certificates", user_email=email)


@router.delete("/{cert_id}")
@limiter.limit("20/minute")
async def delete_certificate(cert_id: int, request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/certificates/{cert_id}", user_email=email)
