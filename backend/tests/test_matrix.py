from time import monotonic
from unittest.mock import patch
from urllib.parse import parse_qs, urlsplit

from fastapi import HTTPException
import pytest

from app.services import matrix


@pytest.fixture(autouse=True)
def clear_cache():
    matrix._cache.clear()
    yield
    matrix._cache.clear()


def table(url, timeout=8):
    parsed = urlsplit(url)
    params = parse_qs(parsed.query)
    sources = [int(item) for item in params["sources"][0].split(";")]
    destinations = [int(item) for item in params["destinations"][0].split(";")]
    return {
        "code": "Ok",
        "distances": [
            [0 if i == j else (i + 1) * 1000 for j in destinations] for i in sources
        ],
        "durations": [
            [0 if i == j else (i + 1) * 60 for j in destinations] for i in sources
        ],
    }


def test_directed_matrix_units_and_cached_provider_call_count():
    points = [(-12, -77), (-12.01, -77.01), (-12.02, -77.02)]
    with patch.object(matrix, "fetch_json", side_effect=table) as fetch:
        distance, duration, first = matrix.road_matrix(points, monotonic() + 10)
        second_distance, second_duration, second = matrix.road_matrix(
            points, monotonic() + 10
        )
    assert distance[0][1] == 1 and distance[1][0] == 2
    assert duration[0][1] == 1 and duration[1][0] == 2
    assert first["provider_calls"] == 1 and second["provider_calls"] == 0
    assert second["cache_hit"] and fetch.call_count == 1
    assert second_distance == distance and second_duration == duration


def test_provider_batches_fit_location_limit_and_cache_is_bounded():
    points = [(-12 - i * 0.001, -77) for i in range(41)]
    with patch.object(matrix, "fetch_json", side_effect=table) as fetch:
        distance, _, metadata = matrix.road_matrix(points, monotonic() + 10)
        assert len(distance) == 41 and metadata["provider_calls"] == 4
        for call in fetch.call_args_list:
            coordinates = urlsplit(call.args[0]).path.split("/")[-1].split(";")
            assert len(coordinates) <= 80
        for i in range(6):
            matrix.road_matrix(
                [(-11 - i * 0.001, -77), (-11.01, -77.01)], monotonic() + 10
            )
    assert len(matrix._cache) == matrix.MAX_CACHE_ENTRIES


@pytest.mark.parametrize(
    "response",
    [
        {},
        {"code": "NoTable"},
        {"code": "Ok", "distances": [[None]], "durations": [[0]]},
        {"code": "Ok", "distances": [], "durations": []},
    ],
)
def test_invalid_or_disconnected_matrix_never_cached(response):
    with patch.object(matrix, "fetch_json", return_value=response):
        with pytest.raises(HTTPException) as error:
            matrix.road_matrix([(-12, -77)], monotonic() + 10)
    assert error.value.status_code == 503 and not matrix._cache


def test_matrix_deadline_and_provider_failure():
    with pytest.raises(HTTPException) as error:
        matrix.road_matrix([(-12, -77)], monotonic() - 1)
    assert error.value.status_code == 503
    with patch.object(matrix, "fetch_json", side_effect=TimeoutError):
        with pytest.raises(HTTPException):
            matrix.road_matrix([(-12, -77)], monotonic() + 10)


def test_road_shape_requires_valid_complete_legs():
    valid = {
        "code": "Ok",
        "routes": [
            {
                "geometry": {
                    "type": "LineString",
                    "coordinates": [[-77, -12], [-77.01, -12.01]],
                },
                "legs": [{"distance": 1000, "duration": 120}],
            }
        ],
    }
    with patch.object(matrix, "fetch_json", return_value=valid):
        geometry, legs = matrix.road_shape(
            [(-12, -77), (-12.01, -77.01)], monotonic() + 10
        )
    assert geometry["type"] == "LineString" and legs == [(1, 2)]
    valid["routes"][0]["legs"] = []
    with patch.object(matrix, "fetch_json", return_value=valid):
        with pytest.raises(HTTPException):
            matrix.road_shape([(-12, -77), (-12.01, -77.01)], monotonic() + 10)
