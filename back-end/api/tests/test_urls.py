from django.test import SimpleTestCase
from django.urls import resolve, reverse
from drf_spectacular.views import (  # type: ignore
    SpectacularAPIView,
    SpectacularSwaggerView,
)
from rest_framework import status
from rest_framework.test import APIClient

from api.views.admin import BanUserView, UnbanUserView
from api.views.auth import CreateUserView, RevokeTokenAPIView, TokenAPIView
from api.views.user import (
    DeleteUserView,
    UpdateUserInfoView,
    UpdateUserPasswordView,
    ViewUserInfoView,
)
from api.views.user_profile import (
    UpdateUserProfileView,
    UserProfileView,
)


class TestUrls(SimpleTestCase):
    def test_register_url(self):
        url = reverse("register new user")
        self.assertEqual(resolve(url).func.view_class, CreateUserView)  # type: ignore

    def test_user_profile_url(self):
        url = reverse("retrieve user profile")
        self.assertEqual(resolve(url).func.view_class, UserProfileView)  # type: ignore

    # Deprecated: User Profile is auto created with user account now
    # def test_create_user_profile_url(self):
    #     url = reverse("create new user profile")
    #     self.assertEqual(resolve(url).func.view_class, CreateUserProfileView)  # type: ignore

    def test_update_user_profile_url(self):
        url = reverse("update user profile")
        self.assertEqual(resolve(url).func.view_class, UpdateUserProfileView)  # type: ignore

    def test_delete_user_url(self):
        url = reverse("delete user account")
        self.assertEqual(resolve(url).func.view_class, DeleteUserView)  # type: ignore

    def test_user_info_url(self):
        url = reverse("retrieve user info")
        self.assertEqual(resolve(url).func.view_class, ViewUserInfoView)  # type: ignore

    def test_update_user_info_url(self):
        url = reverse("update user info")
        self.assertEqual(resolve(url).func.view_class, UpdateUserInfoView)  # type: ignore

    def test_update_password_url(self):
        url = reverse("change user password")
        self.assertEqual(resolve(url).func.view_class, UpdateUserPasswordView)  # type: ignore

    def test_ban_user_url(self):
        url = reverse("ban a user")
        self.assertEqual(resolve(url).func.view_class, BanUserView)  # type: ignore

    def test_unban_user_url(self):
        url = reverse("unban a user")
        self.assertEqual(resolve(url).func.view_class, UnbanUserView)  # type: ignore

    def test_schema_url(self):
        url = reverse("schema")
        self.assertEqual(resolve(url).func.view_class, SpectacularAPIView)  # type: ignore

    def test_overview_url(self):
        url = reverse("overview")
        self.assertEqual(resolve(url).func.view_class, SpectacularSwaggerView)  # type: ignore

    def test_login_url(self):
        url = reverse("login and acquire token")
        self.assertEqual(resolve(url).func.view_class, TokenAPIView)  # type: ignore

    def test_logout_url(self):
        url = reverse("logout and revoke token")
        self.assertEqual(resolve(url).func.view_class, RevokeTokenAPIView)  # type: ignore

    def test_invalid_url(self):
        client = APIClient()
        response = client.get("/invalid/url/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_url_patterns(self):
        urlpatterns = [
            reverse("register new user"),
            reverse("retrieve user profile"),
            reverse("update user profile"),
            reverse("delete user account"),
            reverse("retrieve user info"),
            reverse("update user info"),
            reverse("change user password"),
            reverse("ban a user"),
            reverse("unban a user"),
            reverse("schema"),
            reverse("overview"),
            reverse("login and acquire token"),
            reverse("logout and revoke token"),
        ]
        for url in urlpatterns:
            self.assertIsNotNone(resolve(url))
