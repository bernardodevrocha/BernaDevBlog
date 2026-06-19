from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    BLOG_DATABASE_URL: str
    INTERNAL_SECRET: str

    class Config:
        env_file = ".env"


settings = Settings()
