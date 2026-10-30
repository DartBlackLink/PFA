"""Bounded JSON transport. No redirects or implicit environment proxies."""

import json

import httpx

MAX_RESPONSE_BYTES = 2 * 1024 * 1024


def fetch_json(url, timeout=8):
    with httpx.Client(
        timeout=timeout, follow_redirects=False, trust_env=False
    ) as client:
        with client.stream(
            "GET",
            url,
            headers={"User-Agent": "EcoLogistica/1.0", "Accept": "application/json"},
        ) as response:
            response.raise_for_status()
            chunks = bytearray()
            for chunk in response.iter_bytes():
                chunks.extend(chunk)
                if len(chunks) > MAX_RESPONSE_BYTES:
                    raise ValueError("Provider response too large")
            return json.loads(chunks)
