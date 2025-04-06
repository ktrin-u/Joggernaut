from rest_framework import permissions
from rest_framework.request import Request


class isBanned(permissions.BasePermission):
    message = "User is banned"

    def has_permission(self, request: Request, view) -> bool:
        try:
            user = request.user
            return user.is_active
        except Exception:
            return True
