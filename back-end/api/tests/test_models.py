from django.test import TestCase
from django.core.exceptions import ValidationError
from api.models import User, WorkoutRecord, UserAuditLog, UserProfiles, UserSettings, Status, Gender
from datetime import datetime, date
from django.utils.timezone import make_aware

class TestUserModel(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        ) # type: ignore

    def test_create_user(self):
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

    def test_ban_user(self):
        self.user.ban()
        self.assertFalse(self.user.is_active)

    def test_unban_user(self):
        self.user.ban()
        self.user.unban()
        self.assertTrue(self.user.is_active)

    def test_ban_banned_user(self):
        self.user.ban()
        self.assertFalse(self.user.is_active)
        self.user.ban()
        self.assertFalse(self.user.is_active)

    def test_unban_active_user(self):
        self.assertTrue(self.user.is_active)
        self.user.unban()
        self.assertTrue(self.user.is_active)

class TestWorkoutRecord(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="activity@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        )  # type: ignore
        self.workout = WorkoutRecord.objects.create(userid=self.user, calories=500, steps=10000)

    def test_workout_creation(self):
        self.assertEqual(self.workout.calories, 500)
        self.assertEqual(self.workout.steps, 10000)

    def test_workout_belongs_to_user(self):
        self.assertEqual(self.workout.userid, self.user)

class TestUserAuditLog(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="log@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        ) # type: ignore
        self.log = UserAuditLog.objects.create(
            userid=self.user,
            action="Login",
            details="User logged in",
            timestamp=make_aware(datetime.now())
        )

    def test_audit_log_creation(self):
        self.assertEqual(self.log.action, "Login")
        self.assertEqual(self.log.details, "User logged in")

    def test_log_belongs_to_user(self):
        self.assertEqual(self.log.userid, self.user)

class TestUserProfiles(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="profile@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        ) # type: ignore
        self.profile = UserProfiles.objects.create(
            userid=self.user,
            accountname="First Last",
            dateofbirth=date(2025, 2, 13),
            gender=Gender.MALE,
            address="",
            height_cm=999.9,
            weight_kg=99.9
        )
    def test_profile_creation(self):
        self.assertEqual(self.profile.accountname, "First Last")
        self.assertEqual(self.profile.gender, Gender.MALE)

    def test_profile_belongs_to_user(self):
        self.assertEqual(self.profile.userid, self.user)

    def test_profile_fields(self):
        self.assertEqual(self.profile.height_cm, 999.9)
        self.assertEqual(self.profile.weight_kg, 99.9)

class TestUserSettings(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="settings@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@"
        ) # type: ignore
        self.setting = UserSettings.objects.create(userid=self.user, status=Status.ONLINE)

    def test_settings_creation(self):
        self.assertEqual(self.setting.status, Status.ONLINE)

    def test_settings_belongs_to_user(self):
        self.assertEqual(self.setting.userid, self.user)