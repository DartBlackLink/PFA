"""Wasmer ASGI entrypoint; application logic remains in app.main."""
import os
from app.main import app

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=int(os.environ.get('PORT', '8000')), loop='asyncio', http='h11')
