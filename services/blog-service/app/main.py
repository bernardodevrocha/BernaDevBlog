from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import engine, Base
from app.routers import posts, tags, certificates


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield


app = FastAPI(title="Blog Service", docs_url=None, redoc_url=None, lifespan=lifespan)
app.include_router(posts.router)
app.include_router(tags.router)
app.include_router(certificates.router)
