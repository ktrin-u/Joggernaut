from rest_framework import permissions
from rest_framework.request import Request

from api.models import UserSettings


class IsBanned(permissions.BasePermission):
    message = "User is banned"

    def has_permission(self, request: Request, view) -> bool:
        try:
            user = request.user
            return user.is_active
        except Exception:
            return True


class CanEditProfile(permissions.BasePermission):
    message = "User is not allowed to edit their profile"

    def has_permission(self, request: Request, view) -> bool:
        try:
            user = request.user
            settings = UserSettings.objects.get(userid=user)
            return settings.profile_edit
        except Exception:
            return True


class CanShareWorkout(permissions.BasePermission):
    message = "User cannot share their workout data"

    def has_permission(self, request: Request, view) -> bool:
        if request.method == "GET":
            return True
        try:
            user = request.user
            settings = UserSettings.objects.get(userid=user)
            return settings.workout_share
        except Exception:
            return True


class CanJoinLeaderboard(permissions.BasePermission):
    message = "User cannot join the leaderboards"

    def has_permission(self, request: Request, view) -> bool:
        try:
            user = request.user
            settings = UserSettings.objects.get(userid=user)
            return settings.in_leaderboards
        except Exception:
            return True


class CanUserInteract(permissions.BasePermission):
    message = "User cannot interact with other users"

    def has_permission(self, request: Request, view) -> bool:
        try:
            user = request.user
            settings = UserSettings.objects.get(userid=user)
            return settings.user_interact
        except Exception:
            return True
