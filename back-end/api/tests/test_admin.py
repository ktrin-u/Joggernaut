from django.test import TestCase
from django.contrib.admin.sites import site
from api.models import User, WorkoutRecord, UserAuditLog, UserProfiles, UserSettings
from api.admin import (
    UserAdmin, WorkoutRecordAdmin, UserAuditLogAdmin, UserProfilesAdmin, UserSettingsAdmin
)


class TestAdminRegistration(TestCase):
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
