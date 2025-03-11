from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIRequestFactory
from api.permissions import isBanned
from unittest.mock import patch

User = get_user_model()


class TestIsBannedPermission(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )  # type: ignore
        self.factory = APIRequestFactory()
        self.permission = isBanned()

    @patch("api.helper.get_user_object")
    def test_has_permission_user_not_banned(self, mock_get_user):
        mock_get_user.return_value = self.user
        request = self.factory.get("/")
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    @patch("api.helper.get_user_object")
    def test_has_permission_user_banned(self, mock_get_user):
        self.user.is_active = False
        self.user.save()

        mock_get_user.return_value = self.user
        request = self.factory.get("/")
        self.assertFalse(self.permission.has_permission(request, None))  # type: ignore

    @patch("api.helper.get_user_object")
    def test_has_permission_no_user(self, mock_get_user):
        mock_get_user.return_value = None
        request = self.factory.get("/")
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore
