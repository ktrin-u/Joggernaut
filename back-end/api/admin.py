from .models import User, UserActivity, UserAuditLog, UserProfiles, UserSettings
from django.contrib import admin
from .forms import UserChangeForm, SignupForm
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import Group


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = SignupForm
    list_display = ("userid", "email", "phonenumber", "firstname", "lastname", "joindate", "is_superuser", "is_staff", "is_active")
    ordering = ["userid"]


@admin.register(UserActivity)
class UserActivityAdmin(admin.ModelAdmin):
    list_display = ("activityid", "userid", "calories", "steps")
    pass


@admin.register(UserAuditLog)
class UserAuditLogAdmin(admin.ModelAdmin):
    pass


@admin.register(UserProfiles)
class UserProfilesAdmin(admin.ModelAdmin):
    pass


@admin.register(UserSettings)
class UserSettingsAdmin(admin.ModelAdmin):
    pass


admin.site.unregister(Group)  # remove the groups since oauth will be used for scoping


# admin.site.register(
#     [
#         User,
#         UserActivity,
#         UserAuditLog,
#         UserProfiles,
#         UserSettings
#     ]
# )
