from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIRequestFactory

from api.permissions import IsBanned

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
        self.permission = IsBanned()

    def test_has_permission_user_not_banned(self):
        request = self.factory.get("/")
        request.user = self.user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_user_banned(self):
        self.user.is_active = False
        self.user.save()

        request = self.factory.get("/")
        request.user = self.user
        self.assertFalse(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_no_user(self):
        request = self.factory.get("/")
        request.user = self.user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_authenticated_user(self):
        request = self.factory.get("/")
        request.user = self.user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_unauthenticated_user(self):
        request = self.factory.get("/")
        request.user = None  # type: ignore
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_admin_user(self):
        admin_user = User.objects.create_superuser(
            email="admin@email.com",
            phonenumber="09151112222",
            firstname="Admin",
            lastname="User",
            password="adminPass1@",
        )  # type: ignore
        request = self.factory.get("/")
        request.user = admin_user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore

    def test_has_permission_regular_user(self):
        regular_user = User.objects.create_user(
            email="regular@email.com",
            phonenumber="09161112222",
            firstname="Regular",
            lastname="User",
            password="regularPass1@",
        )  # type: ignore
        request = self.factory.get("/")
        request.user = regular_user
        self.assertTrue(self.permission.has_permission(request, None))  # type: ignore
