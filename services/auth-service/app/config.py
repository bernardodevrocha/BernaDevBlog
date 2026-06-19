from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    AUTH_DATABASE_URL: str
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str
    JWT_EXPIRE_MINUTES: int
    INTERNAL_SECRET: str
    ADMIN_EMAIL: str
    ADMIN_PASSWORD: str
    ADMIN_NAME: str

    class Config:
        env_file = ".env"


settings = Settings()
