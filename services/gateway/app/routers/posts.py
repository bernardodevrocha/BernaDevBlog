from fastapi import APIRouter, Depends, Request

from app.config import settings
from app.proxy import forward
from app.security.jwt_guard import require_user_email
from app.security.rate_limit import limiter


router = APIRouter(prefix="/api/posts")


@router.get("")
@limiter.limit("60/minute")
async def list_posts(request: Request):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts")


@router.get("/all")
@limiter.limit("60/minute")
async def list_all_posts(request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts/all", user_email=email)


@router.get("/{slug}")
@limiter.limit("60/minute")
async def get_post(slug: str, request: Request):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts/{slug}")


@router.post("")
@limiter.limit("30/minute")
async def create_post(request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts", user_email=email)


@router.put("/{post_id}")
@limiter.limit("30/minute")
async def update_post(post_id: int, request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts/{post_id}", user_email=email)


@router.delete("/{post_id}")
@limiter.limit("30/minute")
async def delete_post(post_id: int, request: Request, email: str = Depends(require_user_email)):
    return await forward(request.app.state.http, request, f"{settings.BLOG_SERVICE_URL}/posts/{post_id}", user_email=email)
