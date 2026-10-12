from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    ENVIRONMENT: str = "development"
    MONGODB_URL: str = "mongodb://localhost:27017"
    DATABASE_NAME: str = "carevoice_db"
    CORS_ORIGINS: str = "*"

    class Config:
        env_file = ".env"
        extra = "allow"


settings = Settings()
