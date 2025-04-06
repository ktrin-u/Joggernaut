from unittest.mock import MagicMock

from django.contrib.admin.sites import site
from django.test import TestCase

from api.admin import (
    FriendTableAdmin,
    UserAdmin,
    UserAuditLogAdmin,
    UserProfilesAdmin,
    UserSettingsAdmin,
    WorkoutRecordAdmin,
)
from api.models import (
    FriendTable,
    User,
    UserAuditLog,
    UserProfiles,
    UserSettings,
    WorkoutRecord,
)


class TestAdminRegistration(TestCase):
    def setUp(self):
        # Create a test user
        self.user = User.objects.create_user(  # type: ignore
            email="testuser@email.com",
            phonenumber="09171112222",
            firstname="Test",
            lastname="User",
            password="testPass1@",
        )

        # Create a FriendTable instance
        self.friend_table = FriendTable.objects.create(
            fromUserid=self.user,
            toUserid=self.user,
            status="Pending",
        )

    # Tests for admin registration
    def test_user_admin_registered(self):
        self.assertTrue(site.is_registered(User))
        self.assertIsInstance(site._registry[User], UserAdmin)

    def test_user_activity_admin_registered(self):
        self.assertTrue(site.is_registered(WorkoutRecord))
        self.assertIsInstance(site._registry[WorkoutRecord], WorkoutRecordAdmin)

    def test_user_audit_log_admin_registered(self):
        self.assertTrue(site.is_registered(UserAuditLog))
        self.assertIsInstance(site._registry[UserAuditLog], UserAuditLogAdmin)

    def test_user_profiles_admin_registered(self):
        self.assertTrue(site.is_registered(UserProfiles))
        self.assertIsInstance(site._registry[UserProfiles], UserProfilesAdmin)

    def test_user_settings_admin_registered(self):
        self.assertTrue(site.is_registered(UserSettings))
        self.assertIsInstance(site._registry[UserSettings], UserSettingsAdmin)

    # Tests for list_display
    def test_user_admin_list_display(self):
        self.assertEqual(
            UserAdmin.list_display,
            (
                "userid",
                "email",
                "phonenumber",
                "firstname",
                "lastname",
                "last_login",
                "is_superuser",
                "is_staff",
                "is_active",
                "joindate",
            ),
        )

    def test_user_activity_admin_list_display(self):
        self.assertEqual(
            WorkoutRecordAdmin.list_display,
            [
                "workoutid",
                "lastUpdate",
                "userid",
                "calories",
                "steps",
                "creationDate",
                "activityid",
            ],
        )

    def test_user_audit_log_admin_list_display(self):
        self.assertEqual(
            UserAuditLogAdmin.list_display,
            ("timestamp", "logid", "userid", "action", "details"),
        )

    def test_user_profiles_admin_list_display(self):
        self.assertEqual(
            UserProfilesAdmin.list_display,
            [
                "userid__email",
                "accountname",
                "dateofbirth",
                "gender",
                "height_cm",
                "weight_kg",
            ],
        )

    def test_user_settings_admin_list_display(self):
        self.assertEqual(
            UserSettingsAdmin.list_display,
            [
                "userid__email",
                "profile_edit",
                "workout_share",
                "in_leaderboards",
                "user_interact",
            ],
        )

    # Tests for ordering
    def test_user_admin_ordering(self):
        self.assertEqual(UserAdmin.ordering, ["userid"])

    def test_user_activity_admin_ordering(self):
        self.assertEqual(WorkoutRecordAdmin.ordering, ["lastUpdate"])

    def test_user_audit_log_admin_ordering(self):
        self.assertEqual(UserAuditLogAdmin.ordering, ["timestamp"])

    def test_user_profiles_admin_ordering(self):
        self.assertEqual(UserProfilesAdmin.ordering, ["userid"])

    def test_user_settings_admin_ordering(self):
        self.assertEqual(UserSettingsAdmin.ordering, ["userid"])

    # Tests for readonly_fields
    def test_user_admin_readonly_fields(self):
        self.assertEqual(UserAdmin.readonly_fields, ["userid", "last_login", "joindate"])

    def test_user_activity_admin_readonly_fields(self):
        self.assertEqual(WorkoutRecordAdmin.readonly_fields, ["creationDate"])

    def test_user_audit_log_admin_readonly_fields(self):
        self.assertEqual(UserAuditLogAdmin.readonly_fields, ("timestamp", "logid", "userid"))

    def test_user_profiles_admin_readonly_fields(self):
        self.assertEqual(UserProfilesAdmin.readonly_fields, ["userid"])

    def test_user_settings_admin_readonly_fields(self):
        self.assertEqual(UserSettingsAdmin.readonly_fields, ["userid"])

    # Test for get_readonly_fields logic
    def test_friend_table_admin_get_readonly_fields(self):
        # Create a mock request
        mock_request = MagicMock()

        # Create an instance of FriendTableAdmin
        admin_instance = FriendTableAdmin(FriendTable, site)

        # Call get_readonly_fields with a truthy obj
        readonly_fields = admin_instance.get_readonly_fields(mock_request, obj=self.friend_table)
        self.assertEqual(readonly_fields, ["fromUserid", "toUserid"])  # Should return the fields

        # Call get_readonly_fields with a falsy obj
        readonly_fields = admin_instance.get_readonly_fields(mock_request, obj=None)
        self.assertEqual(readonly_fields, [])  # Should return an empty list
