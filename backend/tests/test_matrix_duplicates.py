"""Repeated deliveries keep independent indices without duplicate road calls."""
from time import monotonic
from unittest.mock import patch
from urllib.parse import parse_qs, urlsplit

import pytest
from app.services import matrix


@pytest.fixture(autouse=True)
def isolated_matrix_cache():
    matrix._cache.clear()
    yield
    matrix._cache.clear()


def directed_table(url, timeout):
    query = parse_qs(urlsplit(url).query)
    sources = [int(i) for i in query['sources'][0].split(';')]
    destinations = [int(i) for i in query['destinations'][0].split(';')]
    return {'code': 'Ok',
            'distances': [[0 if i == j else (i+1)*1000 for j in destinations] for i in sources],
            'durations': [[0 if i == j else (i+1)*60 for j in destinations] for i in sources]}


def test_165_positions_query_three_points_once_and_keep_directed_costs():
    a, b, c = (-12.068046, -75.210073), (-12.070855, -75.208325), (-12.049215, -75.197825)
    points = [a]*15 + [a, b, c]*50
    with patch.object(matrix, 'fetch_json', side_effect=directed_table) as fetch:
        distance, duration, info = matrix.road_matrix(points, monotonic()+10)
    assert len(distance) == len(duration) == 165
    assert all(len(row) == 165 for row in distance)
    assert distance[0][16] == duration[0][16] == 1
    assert distance[16][0] == duration[16][0] == 2
    assert distance[0][15] == 0
    assert fetch.call_count == info['provider_calls'] == 1
    assert info['input_locations'] == 165 and info['unique_locations'] == 3
    assert len(urlsplit(fetch.call_args.args[0]).path.split('/')[-1].split(';')) == 3


def test_cache_expands_new_multiplicity_and_caller_cannot_corrupt_it():
    a, b = (-12.068046, -75.210073), (-12.070855, -75.208325)
    with patch.object(matrix, 'fetch_json', side_effect=directed_table) as fetch:
        first, _, _ = matrix.road_matrix([a, b], monotonic()+10)
        first[0][1] = -999
        second, _, info = matrix.road_matrix([a, a, b, b], monotonic()+10)
    assert fetch.call_count == 1 and info['cache_hit']
    assert info['provider_calls'] == 0 and len(second) == 4
    assert second[0][2] == second[1][3] == 1
    assert second[2][0] == 2 and second[0][1] == 0


def test_nearby_but_distinct_points_are_not_rounded_together():
    points = [(-12.068046, -75.210073), (-12.0680461, -75.210073)]
    with patch.object(matrix, 'fetch_json', side_effect=directed_table):
        distance, _, info = matrix.road_matrix(points, monotonic()+10)
    assert info['unique_locations'] == 2 and distance[0][1] == 1


def test_single_unique_location_respects_osrm_two_coordinate_protocol():
    point = (-12.068046, -75.210073)
    with patch.object(matrix, 'fetch_json', side_effect=directed_table) as fetch:
        distance, duration, info = matrix.road_matrix([point]*3, monotonic()+10)
    parsed = urlsplit(fetch.call_args.args[0])
    sent = parsed.path.split('/')[-1].split(';')
    assert len(sent) == 2 and sent[0] == sent[1]
    assert parse_qs(parsed.query)['sources'] == ['0']
    assert parse_qs(parsed.query)['destinations'] == ['0']
    assert info['unique_locations'] == 1 and info['provider_calls'] == 1
    assert distance == duration == [[0, 0, 0] for _ in range(3)]
