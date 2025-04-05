from drf_spectacular.utils import OpenApiExample, extend_schema_serializer
from rest_framework import serializers, status


@extend_schema_serializer(
    examples=[
        OpenApiExample(name="generic", value={"msg": "message about what happened"}),
        OpenApiExample(
            name="success/pass",
            value={
                "msg": "PASS:<success message>",
            },
            status_codes=[status.HTTP_200_OK, status.HTTP_201_CREATED, status.HTTP_202_ACCEPTED],
        ),
        OpenApiExample(
            name="error/fail",
            value={
                "msg": "FAIL:<error or point of failure message>",
            },
            status_codes=[status.HTTP_500_INTERNAL_SERVER_ERROR],
        ),
        OpenApiExample(
            name="malformed parameters",
            value={
                "field_name1": ["field error message"],
                "field_name2": ["field error message"],
            },
            status_codes=[status.HTTP_400_BAD_REQUEST],
        ),
        OpenApiExample(
            name="not found",
            value={
                "msg": "FAIL: <resource identifier> is NOT FOUND",
            },
            status_codes=[
                status.HTTP_404_NOT_FOUND,
            ],
        ),
    ]
)
class MsgSerializer(serializers.Serializer):
    msg = serializers.CharField(default="")


class TargetUserIdSerializer(serializers.Serializer):
    targetid = serializers.UUIDField()
