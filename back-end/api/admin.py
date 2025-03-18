from typing import Any
from django.http import HttpRequest
from .models import User, UserAuditLog, UserProfiles, UserSettings, FriendTable, WorkoutRecord, FriendActivity
from django.contrib import admin
from .forms import UserChangeForm, SignupForm
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import Group


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = SignupForm
    list_display = ("userid", "email", "phonenumber", "firstname", "lastname", "last_login", "is_superuser", "is_staff", "is_active", "joindate")
    ordering = ["userid"]
    readonly_fields = ["userid", "last_login", "joindate"]

    fieldsets = [
        (
            "User Details",
            {
                "fields": ["userid", "email", "phonenumber", "firstname", "lastname", "last_login", "is_superuser", "is_staff", "is_active", "joindate"]
            }
        )
    ]


@admin.register(UserAuditLog)
class UserAuditLogAdmin(admin.ModelAdmin):
    list_display = ("timestamp", "logid", "userid", "action", "details")
    ordering = ["timestamp"]
    readonly_fields = ("timestamp", "logid", "userid")
    pass


@admin.register(UserProfiles)
class UserProfilesAdmin(admin.ModelAdmin):
    list_display = ["userid", "accountname", "dateofbirth", "gender", "address", "height_cm", "weight_kg"]
    ordering = ["userid"]
    readonly_fields = ["userid"]
    pass


@admin.register(UserSettings)
class UserSettingsAdmin(admin.ModelAdmin):
    list_display = ["userid", "status"]
    ordering = ["userid"]
    readonly_fields = ["userid"]
    pass


@admin.register(FriendTable)
class FriendTableAdmin(admin.ModelAdmin):
    list_display = ["lastUpdate", "fromUserid", "toUserid", "status", "creationDate"]
    ordering = ["lastUpdate"]
    # readonly_fields = ["fromUserid", "toUserid"]

    def get_readonly_fields(self, request: HttpRequest, obj: Any | None = ...) -> list[str] | tuple[Any, ...]:
        if obj:
            return ["fromUserid", "toUserid"]
        else:
            return []


@admin.register(WorkoutRecord)
class WorkoutRecordAdmin(admin.ModelAdmin):
    list_display = ["workoutid", "lastUpdate", "userid", "calories", "steps", "creationDate"]
    ordering = ["lastUpdate"]
    readonly_fields = ["creationDate"]


@admin.register(FriendActivity)
class FriendActivityAdmin(admin.ModelAdmin):
    list_display = ["activityid", "activity", "accept", "fromUserid", "toUserid", "acceptDate", "creationDate"]
    ordering = ["activityid", "creationDate"]
    readonly_fields = ["creationDate"]


admin.site.unregister(Group)  # remove the groups since oauth will be used for scoping
