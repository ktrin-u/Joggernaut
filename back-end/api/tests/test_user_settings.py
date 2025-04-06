from django.core.exceptions import ValidationError
from django.test import TestCase

from api.models import User, UserSettings


class TestUserSettings(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(  # type: ignore
            email="settings@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )

    # Status is deprecated
    # def test_invalid_status(self):
    #     with self.assertRaises(ValidationError):
    #         invalid_setting = UserSettings(
    #             userid=self.user,
    #             status="INVALID",  # Invalid status
    #         )
    #         invalid_setting.full_clean()  # Trigger validation

    def test_unique_user_settings(self):
        with self.assertRaises(ValidationError):
            duplicate_setting = UserSettings(
                userid=self.user,
            )
            duplicate_setting.full_clean()  # Trigger validation
