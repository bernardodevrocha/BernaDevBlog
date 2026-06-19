import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.responses import FileResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.certificate import Certificate
from app.schemas.certificate import CertificateOut
from app.security.middleware import require_internal, require_auth

UPLOAD_DIR = "/uploads/certificates"
ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp", "image/gif", "application/pdf"}
MAX_SIZE = 10 * 1024 * 1024  # 10 MB

router = APIRouter(prefix="/certificates", dependencies=[Depends(require_internal)])


@router.get("", response_model=list[CertificateOut])
async def list_certificates(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Certificate).order_by(Certificate.created_at.desc()))
    return result.scalars().all()


@router.get("/file/{filename}")
async def get_file(filename: str):
    path = os.path.join(UPLOAD_DIR, filename)
    if not os.path.isfile(path):
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(path)


@router.post("", response_model=CertificateOut, status_code=status.HTTP_201_CREATED)
async def create_certificate(
    title: str = Form(...),
    issuer: str = Form(...),
    issued_at: str = Form(...),
    file: UploadFile = File(...),
    _: str = Depends(require_auth),
    db: AsyncSession = Depends(get_db),
):
    if file.content_type not in ALLOWED_MIME:
        raise HTTPException(status_code=400, detail="Tipo de arquivo não permitido.")

    content = await file.read()
    if len(content) > MAX_SIZE:
        raise HTTPException(status_code=400, detail="Arquivo excede 10 MB.")

    file_type = "pdf" if file.content_type == "application/pdf" else "image"
    ext = os.path.splitext(file.filename or "")[1] or (".pdf" if file_type == "pdf" else ".jpg")
    filename = f"{uuid.uuid4().hex}{ext}"

    os.makedirs(UPLOAD_DIR, exist_ok=True)
    with open(os.path.join(UPLOAD_DIR, filename), "wb") as f:
        f.write(content)

    cert = Certificate(title=title.strip(), issuer=issuer.strip(), issued_at=issued_at, file_path=filename, file_type=file_type)
    db.add(cert)
    await db.commit()
    await db.refresh(cert)
    return cert


@router.delete("/{cert_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_certificate(cert_id: int, _: str = Depends(require_auth), db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Certificate).where(Certificate.id == cert_id))
    cert = result.scalar_one_or_none()
    if not cert:
        raise HTTPException(status_code=404, detail="Certificate not found")

    path = os.path.join(UPLOAD_DIR, cert.file_path)
    if os.path.isfile(path):
        os.remove(path)

    await db.delete(cert)
    await db.commit()
