from datetime import timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework.response import Response
from rest_framework.test import APIRequestFactory

from api.admin import WorkoutRecordAdmin
from api.helper import (
    get_token_from_header,
    get_user_from_token,
    get_user_object,
    get_user_object_or_404,
)

User = get_user_model()


class TestHelperFuncs(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )  # type: ignore

        self.application = Application.objects.create(
            name="TestApp",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
        )

        self.token = AccessToken.objects.create(
            user=self.user,
            token="valid_token_123",
            application=self.application,
            expires=now() + timedelta(days=1),
        )

        self.factory = APIRequestFactory()

    def test_get_valid_token(self):
        request = self.factory.get("/", HTTP_AUTHORIZATION="Bearer valid_token_123")
        token_type, token = get_token_from_header(request)  # type: ignore
        self.assertEqual(token_type, "Bearer")
        self.assertEqual(token, "valid_token_123")

    def test_get_invalid_token(self):
        request = self.factory.get("/", HTTP_AUTHORIZATION="InvalidFormat")
        token_type, token = get_token_from_header(request)  # type: ignore
        self.assertEqual(token_type, "")
        self.assertEqual(token, "")

        request = self.factory.get("/", HTTP_AUTHORIZATION="Bearer")
        token_type, token = get_token_from_header(request)  # type: ignore
        self.assertEqual(token_type, "")
        self.assertEqual(token, "")

    def test_get_token_while_no_header(self):
        request = self.factory.get("/")
        token_type, token = get_token_from_header(request)  # type: ignore
        self.assertEqual(token_type, "")
        self.assertEqual(token, "")

    def test_get_user_from_valid_token(self):
        user = get_user_from_token("valid_token_123")
        self.assertIsNotNone(user)
        self.assertEqual(user.email, self.user.email)  # type: ignore

    def test_get_user_from_token_invalid(self):
        user = get_user_from_token("invalid_token_456")
        self.assertIsNone(user)

    def test_get_user_object_with_token(self):
        request = self.factory.get("/", HTTP_AUTHORIZATION="Bearer valid_token_123")
        user = get_user_object(request)  # type: ignore
        self.assertIsNotNone(user)
        self.assertEqual(user.email, self.user.email)  # type: ignore

    def test_get_user_object_without_token(self):
        request = self.factory.get("/")
        user = get_user_object(request)  # type: ignore
        self.assertIsNone(user)

    def test_get_user_object_or_404_valid(self):
        request = self.factory.get("/", HTTP_AUTHORIZATION="Bearer valid_token_123")
        user = get_user_object_or_404(request)  # type: ignore
        self.assertIsInstance(user, User)
        self.assertEqual(user.email, self.user.email)  # type: ignore

    def test_get_user_object_or_404_invalid(self):
        request = self.factory.get("/", HTTP_AUTHORIZATION="Bearer invalid_token_456")
        response = get_user_object_or_404(request)  # type: ignore
        self.assertIsInstance(response, Response)
        self.assertEqual(response.status_code, 404)  # type: ignore
        self.assertEqual(response.data["msg"], "unable to find user")  # type: ignore

    def test_get_user_object_or_404_no_token(self):
        request = self.factory.get("/")
        response = get_user_object_or_404(request)  # type: ignore
        self.assertIsInstance(response, Response)
        self.assertEqual(response.status_code, 404)  # type: ignore
        self.assertEqual(response.data["msg"], "unable to find user")  # type: ignore

    def test_user_activity_admin_list_display(self):
        self.assertEqual(
            WorkoutRecordAdmin.list_display,
            ["workoutid", "lastUpdate", "userid", "calories", "steps", "creationDate"],
        )

    def test_user_activity_admin_ordering(self):
        self.assertEqual(WorkoutRecordAdmin.ordering, ["lastUpdate"])

    def test_user_activity_admin_readonly_fields(self):
        self.assertEqual(WorkoutRecordAdmin.readonly_fields, ["creationDate"])
