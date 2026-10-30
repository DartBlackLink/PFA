import io
import json
import unittest
from unittest.mock import patch
from fastapi import HTTPException
from app.api.routes import geocoding as geo


class Geocoding(unittest.TestCase):
    def setUp(self):
        geo._cache.clear()
        geo._next_request = 0

    def response(self, coords=None, country="PE"):
        return {
            "features": [
                {
                    "geometry": {
                        "type": "Point",
                        "coordinates": coords or [-75.21, -12.07],
                    },
                    "properties": {
                        "countrycode": country,
                        "name": "Plaza",
                        "city": "Huancayo",
                        "street": "Calle Real",
                        "housenumber": "123",
                    },
                }
            ]
        }

    def test_search_maps_coordinates_labels_and_caches(self):
        with patch.object(geo, "fetch_json", return_value=self.response()) as fetch:
            data = geo.search("Plaza Huancayo")
            self.assertEqual(data[0]["latitud"], -12.07)
            self.assertEqual(data[0]["longitud"], -75.21)
            self.assertIn("Calle Real 123", data[0]["direccion"])
            self.assertEqual(geo.search("Plaza Huancayo"), data)
            self.assertEqual(fetch.call_count, 1)

    def test_ignores_results_outside_peru(self):
        with patch.object(geo, "fetch_json", return_value=self.response(country="DE")):
            self.assertEqual(geo.search("Plaza Huancayo"), [])

    def test_ignores_invalid_coordinates(self):
        with patch.object(
            geo, "fetch_json", return_value=self.response(coords=[-75.21, 91])
        ):
            self.assertEqual(geo.search("Plaza Huancayo"), [])

    def test_provider_failure_503_not_fake_coordinate(self):
        with patch.object(geo, "fetch_json", side_effect=TimeoutError):
            with self.assertRaises(HTTPException) as caught:
                geo.search("Huancayo")
            self.assertEqual(caught.exception.status_code, 503)
            self.assertFalse(geo._cache)

    def test_rate_limit_for_uncached_requests(self):
        with patch.object(geo, "fetch_json", return_value=self.response()):
            geo.search("Huancayo")
            with self.assertRaises(HTTPException) as caught:
                geo.search("El Tambo")
            self.assertEqual(caught.exception.status_code, 429)

    def test_reverse_uses_provider_without_moving_selected_point(self):
        with patch.object(geo, "fetch_json", return_value=self.response()) as fetch:
            self.assertIn("Huancayo", geo.reverse(-12.07, -75.21)[0]["direccion"])
            self.assertIn("/reverse?", fetch.call_args.args[0])


if __name__ == "__main__":
    unittest.main(verbosity=2)
