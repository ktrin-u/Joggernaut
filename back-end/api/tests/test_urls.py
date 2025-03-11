from django.test import SimpleTestCase
from django.urls import reverse, resolve

from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView  # type: ignore

from api.views.user import (
    UpdateUserInfoView,
    UpdateUserPasswordView,
    DeleteUserView,
    ViewUserInfoView,
)
from api.views.user_profile import (
    UserProfileView,
    UpdateUserProfileView,
    CreateUserProfileView,
)
from api.views.auth import CreateUserView, TokenAPIView, RevokeTokenAPIView
from api.views.admin import BanUserView, UnbanUserView


class TestUrls(SimpleTestCase):

    def test_register_url(self):
        url = reverse("register new user")
        self.assertEqual(resolve(url).func.view_class, CreateUserView)  # type: ignore

    def test_user_profile_url(self):
        url = reverse("retrieve user profile")
        self.assertEqual(resolve(url).func.view_class, UserProfileView)  # type: ignore

    def test_create_user_profile_url(self):
        url = reverse("create new user profile")
        self.assertEqual(resolve(url).func.view_class, CreateUserProfileView)  # type: ignore

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
