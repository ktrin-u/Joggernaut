from rest_framework.response import Response
from rest_framework import status

RESPONSE_USER_NOT_FOUND = Response(
    {
        "msg": "failed to identify user from auth token",
    },
    status=status.HTTP_404_NOT_FOUND,
)
