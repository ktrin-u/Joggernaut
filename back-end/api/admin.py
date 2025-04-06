from typing import Any

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import Group
from django.http import HttpRequest

from .forms import SignupForm, UserChangeForm
from .models import (
    FriendActivity,
    FriendTable,
    GameAchievement,
    GameAchievementLog,
    GameCharacter,
    GameEnemy,
    GameSave,
    User,
    UserAuditLog,
    UserProfiles,
    UserSettings,
    WorkoutRecord,
)


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = SignupForm
    list_display = (
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
    )
    ordering = ["userid"]
    readonly_fields = ["userid", "last_login", "joindate"]

    fieldsets = [
        (
            "User Details",
            {
                "fields": [
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
                ]
            },
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
    list_display = [
        "userid__email",
        "accountname",
        "dateofbirth",
        "gender",
        "height_cm",
        "weight_kg",
    ]
    ordering = ["userid"]
    readonly_fields = ["userid"]
    pass


@admin.register(UserSettings)
class UserSettingsAdmin(admin.ModelAdmin):
    list_display = [
        "userid__email",
        "profile_edit",
        "workout_share",
        "in_leaderboards",
        "user_interact",
    ]
    ordering = ["userid"]
    readonly_fields = ["userid"]
    list_filter = ["profile_edit", "workout_share", "in_leaderboards", "user_interact"]
    pass


@admin.register(FriendTable)
class FriendTableAdmin(admin.ModelAdmin):
    list_display = [
        "lastUpdate",
        "fromUserid__email",
        "toUserid__email",
        "status",
        "creationDate",
    ]
    ordering = ["lastUpdate", "creationDate"]
    # readonly_fields = ["fromUserid", "toUserid"]
    list_filter = ["fromUserid", "toUserid"]

    def get_readonly_fields(
        self, request: HttpRequest, obj: Any | None = ...
    ) -> list[str] | tuple[Any, ...]:
        if obj:
            return ["fromUserid", "toUserid"]
        return []


@admin.register(WorkoutRecord)
class WorkoutRecordAdmin(admin.ModelAdmin):
    list_display = [
        "workoutid",
        "lastUpdate",
        "userid",
        "calories",
        "steps",
        "creationDate",
        "activityid",
    ]
    ordering = ["lastUpdate"]
    readonly_fields = ["creationDate"]
    list_filter = ["userid"]


@admin.register(FriendActivity)
class FriendActivityAdmin(admin.ModelAdmin):
    list_display = [
        "activityid",
        "activity",
        "status",
        "fromUserid",
        "toUserid",
        "statusDate",
        "durationSecs",
        "details",
        "creationDate",
    ]
    ordering = ["activityid", "creationDate"]
    readonly_fields = ["creationDate"]
    list_filter = [
        "activity",
        "status",
        "fromUserid",
        "toUserid",
    ]


@admin.register(GameSave)
class GameSaveAdmin(admin.ModelAdmin):
    list_display = [
        "id",
        "owner__email",
    ]
    ordering = ["id"]
    readonly_fields = ["id"]


@admin.register(GameCharacter)
class GameCharacterAdmin(admin.ModelAdmin):
    list_display = [
        "id",
        "gamesave_id__owner__email",
        "name",
        "color",
        "type",
        "health",
        "speed",
        "strength",
        "stamina",
        "selected",
    ]
    ordering = ["id"]
    list_filter = ["gamesave_id__owner__email"]


@admin.register(GameEnemy)
class GameEnemyAdmin(admin.ModelAdmin):
    list_display = [
        "id",
        "name",
        "health",
        "damage",
        "speed",
        "defense",
    ]
    ordering = ["id"]


@admin.register(GameAchievement)
class GameAchievementAdmin(admin.ModelAdmin):
    list_display = [
        "id",
        "name",
        "description",
    ]
    ordering = ["id"]


@admin.register(GameAchievementLog)
class GameAchievementLogAdmin(admin.ModelAdmin):
    list_display = [
        "date",
        "gamesave_id__owner__email",
        "achievement_id__name",
    ]
    ordering = ["date"]
    list_filter = [
        "gamesave_id__owner__email",
        "achievement_id__name",
    ]


admin.site.unregister(Group)  # remove the groups since oauth will be used for scoping
