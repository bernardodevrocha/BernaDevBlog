from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi.errors import RateLimitExceeded

from app.config import settings
from app.routers import auth, posts, tags, certificates
from app.security.headers import SecurityHeadersMiddleware
from app.security.rate_limit import limiter


@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.http = httpx.AsyncClient(timeout=10.0)
    yield
    await app.state.http.aclose()


app = FastAPI(title="Portfolio API Gateway", docs_url=None, redoc_url=None, lifespan=lifespan)

# ── Security Layer 1: Rate limiting ──────────────────────────────────
app.state.limiter = limiter

@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(status_code=429, content={"detail": "Too many requests. Please slow down."})

# ── Security Layer 2: CORS ────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

# ── Security Layer 3: HTTP security headers ───────────────────────────
app.add_middleware(SecurityHeadersMiddleware)

# ── Routes ────────────────────────────────────────────────────────────
app.include_router(auth.router)
app.include_router(posts.router)
app.include_router(tags.router)
app.include_router(certificates.router)


@app.get("/api/health")
async def health():
    return {"status": "ok"}
