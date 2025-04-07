from datetime import timedelta
from django.test import TestCase
from django.urls import reverse
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient
from api.models import User, PasswordResetToken
from unittest.mock import patch


class TestAuthViews(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create a test user
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171234567",
            firstname="Test",
            lastname="User",
            password="TestPassword123",
        )

        # Create an OAuth2 application
        self.application = Application.objects.create(
            name="Test Application",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
            user=self.user,
        )

        # Create an access token with the required scopes
        self.access_token = AccessToken.objects.create(
            user=self.user,
            scope="read write",
            expires=now() + timedelta(days=1),
            token="test-access-token",
            application=self.application,
        )

        # Authenticate the client with the access token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token.token}")

        # Define URLs
        self.register_url = reverse("register new user")
        self.login_url = reverse("login and acquire token")
        self.logout_url = reverse("logout and revoke token")
        self.forgot_password_url = reverse("send otp for password reset")
        self.reset_password_url = reverse("change forgot password")

    def test_register_user(self):
        """Test user registration."""
        data = {
            "email": "newuser@email.com",
            "phonenumber": "09171234568",
            "firstname": "New",
            "lastname": "User",
            "password": "NewPassword123",
        }
        response = self.client.post(self.register_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("PASS: user", response.json()["msg"])

    def test_login_user(self):
        """Test user login."""
        data = {
            "username": self.user.email,
            "password": "TestPassword123",
        }
        response = self.client.post(self.login_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access_token", response.json())

    def test_logout_user(self):
        """Test user logout."""
        data = {"token": self.access_token.token}
        response = self.client.post(self.logout_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_forgot_password(self):
        """Test sending a password reset token."""
        data = {"email": self.user.email}
        response = self.client.post(self.forgot_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_reset_password(self):
        """Test resetting the password using a token."""
        # Create a password reset token
        token = "test-reset-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        data = {
            "email": self.user.email,
            "token": token,
            "new_password": "NewPassword123",
        }
        response = self.client.post(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_reset_password_invalid_token(self):
        """Test resetting the password with an invalid token."""
        data = {
            "email": self.user.email,
            "token": "invalid-token",
            "new_password": "NewPassword123",
        }
        response = self.client.post(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("invalid token", response.json().get("msg", "").lower())

    def test_reset_password_missing_email(self):
        """Test resetting the password without providing an email."""
        data = {
            "token": "test-reset-token",
            "new_password": "NewPassword123",
        }
        response = self.client.post(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", response.json())

    def test_get_reset_token_valid(self):
        """Test verifying a valid reset token."""
        # Create a password reset token
        token = "test-reset-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        url = f"{self.forgot_password_url}?email={self.user.email}&token={token}"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("valid", response.json().get("msg", "").lower())

    def test_get_reset_token_invalid(self):
        """Test verifying an invalid reset token."""
        url = f"{self.forgot_password_url}?email={self.user.email}&token=invalid-token"
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("invalid", response.json().get("msg", "").lower())

    def test_patch_reset_password(self):
        """Test resetting the password using PATCH."""
        # Create a password reset token
        token = "test-reset-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        data = {
            "email": self.user.email,
            "token": token,
            "new_password": "NewPassword123",
        }
        response = self.client.patch(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("password has been reset", response.json().get("msg", "").lower())

    def test_patch_reset_password_invalid_token(self):
        """Test resetting the password using PATCH with an invalid token."""
        data = {
            "email": self.user.email,
            "token": "invalid-token",
            "new_password": "NewPassword123",
        }
        response = self.client.patch(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("invalid token", response.json().get("msg", "").lower())

    def test_patch_reset_password_valid(self):
        """Test resetting the password with a valid token."""
        # Create a valid password reset token
        token = "valid-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        headers = {
            "HTTP_EMAIL": self.user.email,
            "HTTP_TOKEN": token,
        }
        data = {"new_password": "NewPassword123"}
        response = self.client.patch(self.reset_password_url, data, **headers)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("password has been changed", response.json()["msg"].lower())

    def test_patch_reset_password_invalid_token(self):
        """Test resetting the password with an invalid token."""
        headers = {
            "HTTP_EMAIL": self.user.email,
            "HTTP_TOKEN": "invalid-token",
        }
        data = {"new_password": "NewPassword123"}
        response = self.client.patch(self.reset_password_url, data, **headers)

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertIn("token is invalid", response.json()["msg"].lower())

    def test_patch_reset_password_invalid_password(self):
        """Test resetting the password with invalid password data."""
        # Create a valid password reset token
        token = "valid-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        headers = {
            "HTTP_EMAIL": self.user.email,
            "HTTP_TOKEN": token,
        }
        data = {"new_password": ""}  # Invalid password
        response = self.client.patch(self.reset_password_url, data, **headers)

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("new_password", response.json())

    def test_patch_reset_password_user_not_found(self):
        """Test resetting the password for a non-existent user."""
        headers = {
            "HTTP_EMAIL": "nonexistent@email.com",
            "HTTP_TOKEN": "valid-token",
        }
        data = {"new_password": "NewPassword123"}
        response = self.client.patch(self.reset_password_url, data, **headers)

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("not found", response.json()["msg"].lower())

    def test_patch_reset_password_successful_update(self):
        """Test successful password update and token deletion."""
        # Create a valid password reset token
        token = "valid-token"
        PasswordResetToken.objects.create(user_email=self.user, token=token)

        headers = {
            "HTTP_EMAIL": self.user.email,
            "HTTP_TOKEN": token,
        }
        data = {"new_password": "NewPassword123"}
        response = self.client.patch(self.reset_password_url, data, **headers)

        # Assert the response status and message
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("password has been changed", response.json()["msg"].lower())

        # Assert that the user's password has been updated
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password("NewPassword123"))

        # Assert that the token has been deleted
        token_exists = PasswordResetToken.objects.filter(token=token).exists()
        self.assertFalse(token_exists)

    def test_forgot_password_user_not_found(self):
        """Test forgot password when the user does not exist."""
        data = {"email": "nonexistent@email.com"}
        response = self.client.post(self.forgot_password_url, data)

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("not found", response.json()["msg"].lower())

    @patch("api.models.PasswordResetToken.objects.get")
    def test_forgot_password_generic_exception(self, mock_get):
        """Test forgot password when a generic exception is raised."""
        # Simulate an exception being raised
        mock_get.side_effect = Exception("Simulated exception")

        data = {"email": self.user.email}
        response = self.client.post(self.forgot_password_url, data)

        self.assertEqual(response.status_code, status.HTTP_500_INTERNAL_SERVER_ERROR)
        self.assertIn("error raised", response.json()["msg"].lower())