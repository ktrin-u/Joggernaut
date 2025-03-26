from enum import StrEnum, auto

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiExample, OpenApiResponse
from rest_framework import status

from api.serializers.general import MsgSerializer

OpenApiResponse()

RESPONSEMSG: dict[int, OpenApiResponse] = {
    status.HTTP_200_OK: OpenApiResponse(response=MsgSerializer),
    status.HTTP_404_NOT_FOUND: OpenApiResponse(response=MsgSerializer),
    status.HTTP_400_BAD_REQUEST: OpenApiResponse(response=MsgSerializer),
    status.HTTP_500_INTERNAL_SERVER_ERROR: OpenApiResponse(response=MsgSerializer),
}


class Response(OpenApiResponse):
    # 400 BAD REQUEST
    SERIALIZER_VALIDATION_ERRORS = OpenApiResponse(
        response=OpenApiTypes.OBJECT,
        examples=[
            OpenApiExample(
                name="malformed parameters",
                value={
                    "field_name1": "field error message",
                    "field_name2": "field error message",
                },
            )
        ],
    )
    AUTH_TOKEN_USER_NOT_FOUND = OpenApiResponse(
        response=MsgSerializer,
        description="failed to identify user using auth token",
        examples=[
            OpenApiExample(
                name="user not found",
                value={
                    "msg": "failed to identify user from auth token",
                },
            )
        ],
    )


class Tags(StrEnum):
    ADMIN = auto()
    AUTH = auto()
    USER = auto()
    FRIENDS = auto()
    ACTIVITY = auto()
    PROFILE = auto()
    WORKOUT = auto()
    GAME = auto()
