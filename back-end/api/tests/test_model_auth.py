from unittest.mock import patch

from django.test import TestCase
from django.utils.timezone import now, timedelta

from api.models import User
from api.models.auth import PasswordResetToken
from django_backend.settings import PASSWORD_RESET_TIMEOUT


class TestPasswordResetToken(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171112222",
            firstname="Test",
            lastname="User",
            password="testPass1@",
        )

    def test_token_creation(self):
        token = PasswordResetToken.objects.create(
            user_email=self.user,
            token="testtoken123",
        )
        self.assertEqual(token.user_email, self.user)
        self.assertEqual(token.token, "testtoken123")
        self.assertIsNotNone(token.created_at)

    def test_token_expiration(self):
        # Create a token that is not expired
        token = PasswordResetToken.objects.create(
            user_email=self.user,
            token="validtoken123",
        )
        self.assertFalse(
            token.expired
        )  # Token should not be expired immediately after creation

        # Simulate an expired token by modifying `created_at`
        token.created_at = now() - timedelta(seconds=PASSWORD_RESET_TIMEOUT + 1)
        token.save()
        self.assertTrue(token.expired)  # Token should now be expired

    def test_token_never_expires(self):
        # Mock PASSWORD_RESET_TIMEOUT to 0
        with patch("api.models.auth.PASSWORD_RESET_TIMEOUT", 0):
            token = PasswordResetToken.objects.create(
                user_email=self.user,
                token="neverexpiretoken",
            )
            self.assertFalse(token.expired)  # Token should never expire

    def test_expired_handles_exception(self):
        token = PasswordResetToken.objects.create(
            user_email=self.user,
            token="exceptiontoken",
        )

        # Mock the `created_at` field to simulate an invalid value
        with patch.object(token, "created_at", None):
            self.assertTrue(token.expired)  # Should return True if an exception occurs
