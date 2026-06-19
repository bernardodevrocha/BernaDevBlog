from datetime import datetime
from pydantic import BaseModel


class CertificateOut(BaseModel):
    id: int
    title: str
    issuer: str
    issued_at: str
    file_path: str
    file_type: str
    created_at: datetime

    model_config = {"from_attributes": True}
