from django.test import SimpleTestCase
from rest_framework import status
from rest_framework.response import Response

from api.responses import RESPONSE_USER_NOT_FOUND


class TestResponses(SimpleTestCase):
    def test_response_user_not_found(self):
        response = RESPONSE_USER_NOT_FOUND
        self.assertIsInstance(response, Response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(
            response.data,
            {
                "msg": "failed to identify user from auth token",
            },
        )
