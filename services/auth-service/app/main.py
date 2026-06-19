from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.database import engine, AsyncSessionLocal, Base
from app.models.user import User
from app.config import settings
from app.security.hashing import hash_password
from app.routers import auth
from sqlalchemy import select


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.email == settings.ADMIN_EMAIL))
        if not result.scalar_one_or_none():
            session.add(User(
                name=settings.ADMIN_NAME,
                email=settings.ADMIN_EMAIL,
                hashed_password=hash_password(settings.ADMIN_PASSWORD),
            ))
            await session.commit()

    yield


app = FastAPI(title="Auth Service", docs_url=None, redoc_url=None, lifespan=lifespan)
app.include_router(auth.router)
