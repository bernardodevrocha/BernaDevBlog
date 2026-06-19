from datetime import datetime
from pydantic import BaseModel, field_validator, model_validator
import re


class TagOut(BaseModel):
    id: int
    name: str
    slug: str

    model_config = {"from_attributes": True}


class PostCreate(BaseModel):
    title: str
    summary: str = ""
    content: str
    published: bool = False
    tags: list[str] = []

    @field_validator("title")
    @classmethod
    def title_valid(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Title is required")
        if len(v) > 200:
            raise ValueError("Title must be 200 characters or less")
        if v.startswith("'"):
            raise ValueError("Stop trying do Sqlinjection!!!!!!")
        return v


    @field_validator("summary")
    @classmethod
    def summary_valid(cls, v: str) -> str:
        v = v.strip()
        if len(v) > 500:
            raise ValueError("Summary must be 500 characters or less")
        return v

    @field_validator("content")
    @classmethod
    def content_valid(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("Content is required")
        if v.startswith("<"):
            raise ValueError("You can't execute a script here!")
        return v

    @field_validator("tags")
    @classmethod
    def tags_valid(cls, v: list[str]) -> list[str]:
        cleaned = []
        for tag in v:
            tag = tag.strip()
            if tag and len(tag) <= 50:
                if re.match(r'^[\w\s-]+$', tag):
                    cleaned.append(tag)
        return list(dict.fromkeys(cleaned))  # deduplicate, preserve order


class PostUpdate(BaseModel):
    title: str | None = None
    summary: str | None = None
    content: str | None = None
    published: bool | None = None
    tags: list[str] | None = None

    @field_validator("title")
    @classmethod
    def title_valid(cls, v: str | None) -> str | None:
        if v is not None:
            v = v.strip()
            if not v:
                raise ValueError("Title cannot be empty")
            if len(v) > 200:
                raise ValueError("Title must be 200 characters or less")
        return v

    @field_validator("content")
    @classmethod
    def content_valid(cls, v: str | None) -> str | None:
        if v is not None:
            v = v.strip()
            if not v:
                raise ValueError("Content cannot be empty")
        return v


class PostOut(BaseModel):
    id: int
    title: str
    slug: str
    summary: str
    content: str
    published: bool
    created_at: datetime
    updated_at: datetime
    tags: list[TagOut] = []

    model_config = {"from_attributes": True}


class PostListOut(BaseModel):
    id: int
    title: str
    slug: str
    summary: str
    published: bool
    created_at: datetime
    tags: list[TagOut] = []

    model_config = {"from_attributes": True}


class PaginatedPostsOut(BaseModel):
    items: list[PostListOut]
    total: int
    page: int
    per_page: int
    pages: int