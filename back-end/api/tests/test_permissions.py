from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIRequestFactory

from api.permissions import isBanned

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

    @patch("api.helper.get_user_object")
    def test_has_permission_authenticated_user(self, mock_get_user):
        mock_get_user.return_value = self.user
        request = self.factory.get("/")
        request.user = self.user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    @patch("api.helper.get_user_object")
    def test_has_permission_unauthenticated_user(self, mock_get_user):
        mock_get_user.return_value = None
        request = self.factory.get("/")
        request.user = None  # type: ignore
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    @patch("api.helper.get_user_object")
    def test_has_permission_admin_user(self, mock_get_user):
        admin_user = User.objects.create_superuser(
            email="admin@email.com",
            phonenumber="09151112222",
            firstname="Admin",
            lastname="User",
            password="adminPass1@",
        )  # type: ignore
        mock_get_user.return_value = admin_user
        request = self.factory.get("/")
        request.user = admin_user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    @patch("api.helper.get_user_object")
    def test_has_permission_regular_user(self, mock_get_user):
        regular_user = User.objects.create_user(
            email="regular@email.com",
            phonenumber="09161112222",
            firstname="Regular",
            lastname="User",
            password="regularPass1@",
        )  # type: ignore
        mock_get_user.return_value = regular_user
        request = self.factory.get("/")
        request.user = regular_user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore
