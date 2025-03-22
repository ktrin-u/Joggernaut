from django.test import TestCase
from django.contrib.admin.sites import site
from api.models import User, WorkoutRecord, UserAuditLog, UserProfiles, UserSettings
from api.admin import (
    UserAdmin, WorkoutRecordAdmin, UserAuditLogAdmin, UserProfilesAdmin, UserSettingsAdmin
)


class TestAdminRegistration(TestCase):
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
            ("userid", "email", "phonenumber", "firstname", "lastname", "last_login", "is_superuser", "is_staff", "is_active", "joindate"),
        )

    def test_user_activity_admin_list_display(self):
        self.assertEqual(
            WorkoutRecordAdmin.list_display,
            ["workoutid", "lastUpdate", "userid", "calories", "steps", "creationDate"],
        )

    def test_user_audit_log_admin_list_display(self):
        self.assertEqual(
            UserAuditLogAdmin.list_display,
            ("timestamp", "logid", "userid", "action", "details"),
        )

    def test_user_profiles_admin_list_display(self):
        self.assertEqual(
            UserProfilesAdmin.list_display,
            ["userid", "accountname", "dateofbirth", "gender", "address", "height_cm", "weight_kg"],
        )

    def test_user_settings_admin_list_display(self):
        self.assertEqual(UserSettingsAdmin.list_display, ["userid", "status"])

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