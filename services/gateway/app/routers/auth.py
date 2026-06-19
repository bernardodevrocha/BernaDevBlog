from fastapi import APIRouter, Depends, Request, Response
import httpx

from app.config import settings
from app.proxy import forward
from app.security.rate_limit import limiter


def get_http(request: Request) -> httpx.AsyncClient:
    return request.app.state.http


router = APIRouter(prefix="/api/auth")


@router.post("/login")
@limiter.limit("10/minute")
async def login(request: Request):
    client = request.app.state.http
    return await forward(client, request, f"{settings.AUTH_SERVICE_URL}/auth/login")


@router.post("/logout")
async def logout(request: Request):
    client = request.app.state.http
    return await forward(client, request, f"{settings.AUTH_SERVICE_URL}/auth/logout")


@router.get("/me")
async def me(request: Request):
    client = request.app.state.http
    return await forward(client, request, f"{settings.AUTH_SERVICE_URL}/auth/me")
