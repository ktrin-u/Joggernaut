from rest_framework.response import Response
from rest_framework import status

RESPONSE_USER_NOT_FOUND = Response(
    {
        "msg": "failed to identify user from auth token",
    },
    status=status.HTTP_404_NOT_FOUND,
)

RESPONSE_INVALID_REQUEST = Response(
    {
        "msg": "invalid request",
    },
    status=status.HTTP_400_BAD_REQUEST,
)
