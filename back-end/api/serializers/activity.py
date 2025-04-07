from django.core.exceptions import ValidationError
from drf_spectacular.utils import extend_schema_serializer
from rest_framework import serializers

from typing import Any

from api.models.friends import (
    FriendActivity,
    FriendActivityStatus,
)


class NewActivitySerializer(serializers.ModelSerializer):
    durationSecs = serializers.IntegerField(min_value=0, default=0, help_text="0 means no expiry")

    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["toUserid", "durationSecs"]


@extend_schema_serializer(exclude_fields="activity")
class CreateActivitySerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["fromUserid", "toUserid", "activity", "durationSecs", "details"]

        extra_kwargs = {"details": {"default": ""}}

    def validate(self, attrs):
        if attrs["fromUserid"] == attrs["toUserid"]:
            raise ValidationError(
                {
                    "fromUserid": "cannot target self",
                    "toUserid": "cannot target self",
                }
            )
        return attrs

    def create(self, validated_data) -> FriendActivity:  # type: ignore
        return FriendActivity.objects.create(
            fromUserid=validated_data["fromUserid"],
            toUserid=validated_data["toUserid"],
            activity=validated_data["activity"],
            durationSecs=validated_data["durationSecs"],
        )


class FriendActivitySerializer(serializers.ModelSerializer):
    deadline = serializers.DateTimeField()

    class Meta:  # type: ignore
        model = FriendActivity
        fields = [
            "activityid",
            "fromUserid",
            "toUserid",
            "activity",
            "status",
            "statusDate",
            "durationSecs",
            "details",
            "creationDate",
            "deadline",
        ]

    def to_representation(self, instance: FriendActivity) -> dict[str,Any]:
        ret = super().to_representation(instance)
        if ret["deadline"] is None:
            ret.pop("deadline")
        return ret


class TargetActivitySerializer(serializers.ModelSerializer):
    activityid = serializers.IntegerField(required=True)

    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["activityid", "status"]


class FilterFriendActivitySerializer(serializers.Serializer):
    for activity_status in FriendActivityStatus:
        exec(f"{activity_status.name} = serializers.BooleanField(default=True)")
