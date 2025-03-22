from rest_framework import serializers
from django.core.exceptions import ValidationError
from api.models.friends import FriendActivity, FriendActivityChoices


class PokeFriendSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["fromUserid", "toUserid"]

    def validate(self, attrs):
        if attrs["fromUserid"] == attrs["toUserid"]:
            raise ValidationError(
                {
                    "fromUserid": "cannot poke self",
                    "toUserid": "cannot poke self",
                }
            )
        return attrs

    def create(self, validated_data) -> FriendActivity:
        activity = FriendActivity.objects.create(
            fromUserid=validated_data["fromUserid"],
            toUserid=validated_data["toUserid"],
            activity=FriendActivityChoices.POKE,
        )
        activity.clean()
        return activity


class ChallengeFriendSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["fromUserid", "toUserid"]

    def validate(self, attrs):
        if attrs["fromUserid"] == attrs["toUserid"]:
            raise ValidationError(
                {
                    "fromUserid": "cannot challenge self",
                    "toUserid": "cannot challenge self",
                }
            )
        return attrs

    def create(self, validated_data) -> FriendActivity:
        activity = FriendActivity.objects.create(
            fromUserid=validated_data["fromUserid"],
            toUserid=validated_data["toUserid"],
            activity=FriendActivityChoices.CHALLENGE,
        )
        activity.clean()
        return activity


class FriendActivitySerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendActivity
        fields = [
            "activityid",
            "fromUserid",
            "toUserid",
            "activity",
            "accept",
            "acceptDate",
            "creationDate",
        ]


class TargetActivitySerializer(serializers.ModelSerializer):
    activityid = serializers.IntegerField()

    class Meta:  # type: ignore
        model = FriendActivity
        fields = ["activityid"]
