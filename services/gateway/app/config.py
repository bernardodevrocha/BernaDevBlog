from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    AUTH_SERVICE_URL: str
    BLOG_SERVICE_URL: str
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str
    INTERNAL_SECRET: str
    CORS_ORIGINS: str

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",")]

    class Config:
        env_file = ".env"


settings = Settings()
