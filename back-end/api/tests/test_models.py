from django.test import TestCase
from django.core.exceptions import ValidationError
from api.models import User, UserManager, UserActivity, UserAuditLog, UserProfiles, UserSettings, Status, Gender
from datetime import datetime, date
from django.utils.timezone import make_aware

class TestUserModel(TestCase):
    def test_create_user(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        ) # type: ignore

        self.assertEqual(self.user.email, "test@email.com")
        self.assertTrue(self.user.check_password("testPass1@"))

    def test_create_superuser(self):
        admin = User.objects.create_superuser(
            email="admin@email.com",
            phonenumber="09151112222",
            firstname="Admin",
            lastname="Last",
            password="adminPass1@"
        ) # type: ignore
        self.assertTrue(admin.is_superuser)
        self.assertTrue(admin.is_staff)

    def test_missing_email(self):
        with self.assertRaises(ValueError):
            User.objects.create_user(email="", phonenumber="09171112222", firstname="First", lastname="Last") # type: ignore

    def test_missing_phone(self):
        with self.assertRaises(ValueError):
            User.objects.create_user(email="test2@email.com", phonenumber="", firstname="First", lastname="Last") # type: ignore

    def test_missing_name(self):
        with self.assertRaises(ValueError):
            User.objects.create_user(email="test2@email.com", phonenumber="09171112222", firstname="", lastname="") # type: ignore


class TestUserActivity(TestCase):
    def test_activity_creation(self):
        self.user = User.objects.create_user("activity@email.com", "09181112222", "First", "Last", "testPass1@") # type: ignore
        self.activity = UserActivity.objects.create(userid=self.user, calories=500, steps=10000)

        self.assertEqual(self.activity.calories, 500)
        self.assertEqual(self.activity.steps, 10000)


class TestUserAuditLog(TestCase):
    def test_audit_log_creation(self):
        self.user = User.objects.create_user("log@email.com", "09181112222", "First", "Last", "testPass1@") # type: ignore
        self.log = UserAuditLog.objects.create(userid=self.user, action="Login", details="User logged in", timestamp=make_aware(datetime.now()))

        self.assertEqual(self.log.action, "Login")
        self.assertEqual(self.log.details, "User logged in")


class TestUserProfiles(TestCase):
    def test_profile_creation(self):
        self.user = User.objects.create_user("profile@email.com", "09181112222", "First", "Last", "testPass1@") # type: ignore
        self.profile = UserProfiles.objects.create(
            userid=self.user,
            accountname="First Last",
            dateofbirth=date(2025, 2, 13),
            gender=Gender.MALE,
            address="",
            height_cm=999.9,
            weight_kg=99.9
        )
        self.assertEqual(self.profile.accountname, "First Last")
        self.assertEqual(self.profile.gender, Gender.MALE)


class TestUserSettings(TestCase):
    def test_settings_creation(self):
        self.user = User.objects.create_user("settings@email.com", "09181112222", "First", "Last", "testPass1@") # type: ignore
        self.setting = UserSettings.objects.create(userid=self.user, status=Status.ONLINE)

        self.assertEqual(self.setting.status, Status.ONLINE)
