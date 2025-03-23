from rest_framework import serializers
from django.core.exceptions import ValidationError
from api.models.friends import (
    FriendActivity,
    FriendActivityStatus,
)


class NewActivitySerializer(serializers.ModelSerializer):
    durationSecs = serializers.IntegerField(
        min_value=0, default=0, help_text="0 means no expiry"
    )

    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["toUserid", "durationSecs"]


class CreateActivitySerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["fromUserid", "toUserid", "durationSecs"]

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
        activity = FriendActivity.objects.create(
            fromUserid=validated_data["fromUserid"],
            toUserid=validated_data["toUserid"],
            activity=validated_data["activity_type"],
            durationSecs=validated_data["durationSecs"],
        )
        return activity


class FriendActivitySerializer(serializers.ModelSerializer):
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
            "creationDate",
        ]


class TargetActivitySerializer(serializers.ModelSerializer):
    activityid = serializers.IntegerField(required=True)

    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["activityid"]


class FilterFriendActivitySerializer(serializers.Serializer):
    for activity_status in FriendActivityStatus:
        exec(f"{activity_status.name} = serializers.BooleanField(default=True)")
