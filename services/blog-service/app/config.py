from pydantic_settings import BaseSettings
from pydantic import model_validator


class Settings(BaseSettings):
    BLOG_DATABASE_URL: str = ""
    INTERNAL_SECRET: str

    # Partes individuais passadas pelo ECS
    DB_HOST: str = ""
    DB_USER: str = ""
    DB_NAME_BLOG: str = "blog_db"
    DB_PASSWORD: str = ""

    @model_validator(mode="after")
    def build_database_url(self) -> "Settings":
        if not self.BLOG_DATABASE_URL and self.DB_HOST:
            self.BLOG_DATABASE_URL = (
                f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASSWORD}"
                f"@{self.DB_HOST}:5432/{self.DB_NAME_BLOG}"
            )
        return self

    class Config:
        env_file = ".env"


settings = Settings()
