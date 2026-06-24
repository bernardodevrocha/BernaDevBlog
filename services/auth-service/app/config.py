from pydantic_settings import BaseSettings
from pydantic import model_validator


class Settings(BaseSettings):
    AUTH_DATABASE_URL: str = ""
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str
    JWT_EXPIRE_MINUTES: int
    INTERNAL_SECRET: str
    ADMIN_EMAIL: str
    ADMIN_PASSWORD: str
    ADMIN_NAME: str

    # Partes individuais passadas pelo ECS
    DB_HOST: str = ""
    DB_USER: str = ""
    DB_NAME_AUTH: str = "auth_db"
    DB_PASSWORD: str = ""

    @model_validator(mode="after")
    def build_database_url(self) -> "Settings":
        if not self.AUTH_DATABASE_URL and self.DB_HOST:
            self.AUTH_DATABASE_URL = (
                f"postgresql+asyncpg://{self.DB_USER}:{self.DB_PASSWORD}"
                f"@{self.DB_HOST}:5432/{self.DB_NAME_AUTH}"
            )
        return self

    class Config:
        env_file = ".env"


settings = Settings()
