from django.core.exceptions import ValidationError
from django.test import TestCase

from api.models import Status, User, UserSettings


class TestUserSettings(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="settings@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )
        self.setting = UserSettings.objects.create(
            userid=self.user, status=Status.ONLINE
        )

    def test_settings_creation(self):
        self.assertEqual(self.setting.status, Status.ONLINE)

    def test_settings_belongs_to_user(self):
        self.assertEqual(self.setting.userid, self.user)

    def test_invalid_status(self):
        with self.assertRaises(ValidationError):
            invalid_setting = UserSettings(
                userid=self.user,
                status="INVALID",  # Invalid status
            )
            invalid_setting.full_clean()  # Trigger validation

    def test_unique_user_settings(self):
        with self.assertRaises(ValidationError):
            duplicate_setting = UserSettings(
                userid=self.user,
                status=Status.IDLE,
            )
            duplicate_setting.full_clean()  # Trigger validation

    def test_update_status(self):
        self.setting.status = Status.DND
        self.setting.save()
        self.assertEqual(self.setting.status, Status.DND)
