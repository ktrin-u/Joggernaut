from django.test import SimpleTestCase
from drf_spectacular.utils import OpenApiExample, OpenApiResponse
from drf_spectacular.types import OpenApiTypes
from api.serializers.general import MsgSerializer
from api.schema_docs import Response, Tags

class TestSchemaDocs(SimpleTestCase):

    def test_serializer_validation_errors(self):
        response = Response.SERIALIZER_VALIDATION_ERRORS
        self.assertIsInstance(response, OpenApiResponse)
        self.assertEqual(response.response, OpenApiTypes.OBJECT)
        self.assertEqual(len(response.examples), 1)
        example = response.examples[0]
        self.assertIsInstance(example, OpenApiExample)
        self.assertEqual(example.name, "malformed parameters")
        self.assertEqual(example.value, {
            "field_name1": "field error message",
            "field_name2": "field error message",
        })

    def test_auth_token_user_not_found(self):
        response = Response.AUTH_TOKEN_USER_NOT_FOUND
        self.assertIsInstance(response, OpenApiResponse)
        self.assertEqual(response.response, MsgSerializer)
        self.assertEqual(response.description, "failed to identify user using auth token")
        self.assertEqual(len(response.examples), 1)
        example = response.examples[0]
        self.assertIsInstance(example, OpenApiExample)
        self.assertEqual(example.name, "user not found")
        self.assertEqual(example.value, {
            "msg": "failed to identify user from auth token",
        })

    def test_tags_enum(self):
        self.assertEqual(Tags.ADMIN.name, "ADMIN")
        self.assertEqual(Tags.AUTH.name, "AUTH")
        self.assertEqual(Tags.USER.name, "USER")
        self.assertEqual(Tags.FRIENDS.name, "FRIENDS")
        self.assertEqual(Tags.PROFILE.name, "PROFILE")
        self.assertEqual(Tags.WORKOUT.name, "WORKOUT")