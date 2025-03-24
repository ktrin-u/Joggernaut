from rest_framework import serializers

from drf_spectacular.utils import extend_schema_serializer, OpenApiExample

@extend_schema_serializer(
    examples=[
        OpenApiExample(
            name="generic",
            value={
                "msg":"message about what happened"
            }
        ),
        OpenApiExample(
            name="success/pass",
            value={
                "msg":"PASS:<success message>",
            }
        ),
        OpenApiExample(
            name="error/fail",
            value={
                "msg":"ERROR:<error or point of failure message>",
            }
        ),
        OpenApiExample(
            name="malformed parameters",
            value={
                "field_name1": "field error message",
                "field_name2": "field error message",
            },
        ),
    ]
)
class MsgSerializer(serializers.Serializer):
    msg = serializers.CharField(default="")


class TargetUserIdSerializer(serializers.Serializer):
    targetid = serializers.UUIDField()
