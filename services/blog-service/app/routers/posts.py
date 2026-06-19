import time
from math import ceil
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from slugify import slugify

from app.database import get_db
from app.models.post import Post, Tag, post_tags
from app.schemas.post import PostCreate, PostUpdate, PostOut, PostListOut, PaginatedPostsOut
from app.security.middleware import require_internal, require_auth
from app.security.sanitizer import sanitize_text

router = APIRouter(prefix="/posts", dependencies=[Depends(require_internal)])


@router.get("", response_model=PaginatedPostsOut)
async def list_posts(
    tag: str | None = None,
    page: int = Query(1, ge=1, description="Page number"),
    per_page: int = Query(10, ge=1, le=50, description="Items per page"),
    db: AsyncSession = Depends(get_db),
):
    # Build ID subquery to avoid join+selectinload row duplication
    id_query = select(Post.id).where(Post.published == True)
    if tag:
        id_query = (
            id_query
            .join(post_tags, Post.id == post_tags.c.post_id)
            .join(Tag, Tag.id == post_tags.c.tag_id)
            .where(Tag.slug == tag)
        )

    total: int = (await db.execute(select(func.count()).select_from(id_query.subquery()))).scalar()

    result = await db.execute(
        select(Post)
        .where(Post.id.in_(id_query))
        .options(selectinload(Post.tags))
        .order_by(Post.created_at.desc())
        .offset((page - 1) * per_page)
        .limit(per_page)
    )

    return PaginatedPostsOut(
        items=result.scalars().all(),
        total=total,
        page=page,
        per_page=per_page,
        pages=ceil(total / per_page) if total else 0,
    )


@router.get("/all", response_model=list[PostListOut])
async def list_all_posts(_: str = Depends(require_auth), db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Post).options(selectinload(Post.tags)).order_by(Post.created_at.desc())
    )
    return result.scalars().all()


@router.get("/{slug}", response_model=PostOut)
async def get_post(slug: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Post).where(Post.slug == slug, Post.published == True).options(selectinload(Post.tags))
    )
    post = result.scalar_one_or_none()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    return post


@router.post("", response_model=PostOut, status_code=status.HTTP_201_CREATED)
async def create_post(body: PostCreate, _: str = Depends(require_auth), db: AsyncSession = Depends(get_db)):
    slug = slugify(sanitize_text(body.title))
    existing = await db.execute(select(Post).where(Post.slug == slug))
    if existing.scalar_one_or_none():
        slug = f"{slug}-{int(time.time())}"

    post = Post(
        title=sanitize_text(body.title),
        slug=slug,
        summary=sanitize_text(body.summary),
        content=body.content,  # raw markdown stored; sanitized on render
        published=body.published,
    )

    for tag_name in body.tags:
        tag_slug = slugify(tag_name)
        tag_result = await db.execute(select(Tag).where(Tag.slug == tag_slug))
        tag = tag_result.scalar_one_or_none()
        if not tag:
            tag = Tag(name=sanitize_text(tag_name), slug=tag_slug)
            db.add(tag)
        post.tags.append(tag)

    db.add(post)
    await db.commit()
    await db.refresh(post)

    result = await db.execute(select(Post).where(Post.id == post.id).options(selectinload(Post.tags)))
    return result.scalar_one()


@router.put("/{post_id}", response_model=PostOut)
async def update_post(post_id: int, body: PostUpdate, _: str = Depends(require_auth), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Post).where(Post.id == post_id).options(selectinload(Post.tags)))
    post = result.scalar_one_or_none()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    if body.title is not None:
        post.title = sanitize_text(body.title)
    if body.summary is not None:
        post.summary = sanitize_text(body.summary)
    if body.content is not None:
        post.content = body.content
    if body.published is not None:
        post.published = body.published

    if body.tags is not None:
        post.tags.clear()
        for tag_name in body.tags:
            tag_slug = slugify(tag_name)
            tag_result = await db.execute(select(Tag).where(Tag.slug == tag_slug))
            tag = tag_result.scalar_one_or_none()
            if not tag:
                tag = Tag(name=sanitize_text(tag_name), slug=tag_slug)
                db.add(tag)
            post.tags.append(tag)

    await db.commit()
    result = await db.execute(select(Post).where(Post.id == post_id).options(selectinload(Post.tags)))
    return result.scalar_one()


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_post(post_id: int, _: str = Depends(require_auth), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Post).where(Post.id == post_id))
    post = result.scalar_one_or_none()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    await db.delete(post)
    await db.commit()
