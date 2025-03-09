from drf_spectacular.utils import OpenApiExample, OpenApiResponse
from drf_spectacular.types import OpenApiTypes
from enum import StrEnum, auto


class Response:
    SERIALIZER_VALIDTION_ERRORS = OpenApiResponse(
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


class Tags(StrEnum):
    ADMIN = auto()
    AUTH = auto()
    USER = auto()
    FRIENDS = auto()
    PROFILE = auto()