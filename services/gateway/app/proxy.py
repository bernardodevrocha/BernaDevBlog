import httpx
from fastapi import Request, Response

from app.config import settings

_EXCLUDED_REQUEST_HEADERS = {"host", "content-length", "transfer-encoding"}
_EXCLUDED_RESPONSE_HEADERS = {"transfer-encoding", "content-encoding"}


def _build_headers(request: Request, user_email: str | None = None) -> dict:
    headers = {
        k: v for k, v in request.headers.items()
        if k.lower() not in _EXCLUDED_REQUEST_HEADERS
    }
    headers["X-Internal-Secret"] = settings.INTERNAL_SECRET
    if user_email:
        headers["X-User-Email"] = user_email
    else:
        headers.pop("X-User-Email", None)
    return headers


async def forward(
    client: httpx.AsyncClient,
    request: Request,
    target_url: str,
    user_email: str | None = None,
) -> Response:
    body = await request.body()
    headers = _build_headers(request, user_email)

    upstream = await client.request(
        method=request.method,
        url=target_url,
        content=body,
        headers=headers,
        params=dict(request.query_params),
        follow_redirects=False,
    )

    response_headers = {
        k: v for k, v in upstream.headers.items()
        if k.lower() not in _EXCLUDED_RESPONSE_HEADERS
    }

    return Response(
        content=upstream.content,
        status_code=upstream.status_code,
        headers=response_headers,
        media_type=upstream.headers.get("content-type"),
    )
