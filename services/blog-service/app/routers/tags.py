from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.post import Tag
from app.schemas.post import TagOut
from app.security.middleware import require_internal

router = APIRouter(prefix="/tags", dependencies=[Depends(require_internal)])


@router.get("", response_model=list[TagOut])
async def list_tags(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Tag).order_by(Tag.name))
    return result.scalars().all()
