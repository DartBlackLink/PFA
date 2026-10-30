"""Bound request size before form/JSON parsing, including chunked requests."""

from starlette.responses import JSONResponse


class RequestSizeLimitMiddleware:
    def __init__(self, app, max_bytes=65536):
        self.app = app
        self.max_bytes = max_bytes

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http" or scope["method"] not in ("POST", "PUT", "PATCH"):
            await self.app(scope, receive, send)
            return
        headers = dict(scope["headers"])
        try:
            length = int(headers.get(b"content-length", b"0"))
        except ValueError:
            await JSONResponse(
                {"detail": "Longitud de petición inválida."}, status_code=400
            )(scope, receive, send)
            return
        if length < 0:
            await JSONResponse(
                {"detail": "Longitud de petición inválida."}, status_code=400
            )(scope, receive, send)
            return
        if length > self.max_bytes:
            await JSONResponse(
                {"detail": "La petición supera el tamaño permitido."}, status_code=413
            )(scope, receive, send)
            return
        body = bytearray()
        while True:
            message = await receive()
            if message["type"] == "http.disconnect":
                return
            body.extend(message.get("body", b""))
            if len(body) > self.max_bytes:
                await JSONResponse(
                    {"detail": "La petición supera el tamaño permitido."},
                    status_code=413,
                )(scope, receive, send)
                return
            if not message.get("more_body", False):
                break
        consumed = False

        async def replay():
            nonlocal consumed
            if not consumed:
                consumed = True
                return {"type": "http.request", "body": bytes(body), "more_body": False}
            return await receive()

        await self.app(scope, replay, send)
