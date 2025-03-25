from rest_framework import permissions
from rest_framework.request import Request

from . import helper


class isBanned(permissions.BasePermission):
    message = "User is banned"

    def has_permission(self, request: Request, view) -> bool:
        user = helper.get_user_object(request)
        if user is None:
            return True
        return user.is_active
