from enum import StrEnum, auto
from drf_spectacular.types import OpenApiTypes
from api.serializers.general import MsgSerializer
from drf_spectacular.utils import OpenApiExample, OpenApiResponse


class Response:
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
        ]
    )

    # 404 NOT FOUND
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
