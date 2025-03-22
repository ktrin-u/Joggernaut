from rest_framework import serializers
from django.core.exceptions import ValidationError
from api.models import FriendTable
from typing import Any
from django.db.models import Q


class ToUserIdSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendTable
        fields = ["toUserid"]


class FromUserIdSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendTable
        fields = ["fromUserid"]


class FriendTableSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = FriendTable
        fields = [
            "friendid",
            "fromUserid",
            "toUserid",
            "status",
            "creationDate",
            "lastUpdate",
        ]


class FriendsListResponseSerializer(serializers.Serializer):
    friends = serializers.ListField(allow_empty=True)

    def validate_friends(self, value):
        if not all(isinstance(x, FriendTable) for x in value):
            raise ValidationError(
                {"friends": "list contents must be of type FriendTable"}
            )
        return value


class PendingFriendsListResponseSerializer(serializers.Serializer):
    sent = serializers.ListField(allow_empty=True)
    received = serializers.ListField(allow_empty=True)

    def validate_sent(self, value):
        if not all(isinstance(x, FriendTable) for x in value):
            raise ValidationError({"sent": "list contents must be of type FriendTable"})
        return value

    def validate_received(self, value):
        if not all(isinstance(x, FriendTable) for x in value):
            raise ValidationError(
                {"received": "list contents must be of type FriendTable"}
            )
        return value


class CreateFriendSerializer(serializers.ModelSerializer):
    class Meta:  # type:ignore
        model = FriendTable
        fields = ["fromUserid", "toUserid"]  # status is set to default of PENDING

    def validate(self, attrs) -> Any:
        if self.Meta.model.objects.filter(
            Q(fromUserid=attrs["fromUserid"], toUserid=attrs["toUserid"])
            | Q(fromUserid=attrs["toUserid"], toUserid=attrs["fromUserid"])
        ).exists():
            raise ValidationError(
                {
                    "fromUserid": "friendship entry already exists",
                    "toUserid": "friendship entry already exists",
                }
            )

        if attrs["fromUserid"] == attrs["toUserid"]:
            raise ValidationError(
                {
                    "fromUserid": "should not match with toUserid",
                    "toUserid": "should not match with fromUserid",
                }
            )
        return attrs

    def create(self, validated_data) -> FriendTable:
        friendrequest = FriendTable.objects.create(
            fromUserid=validated_data["fromUserid"],
            toUserid=validated_data["toUserid"],
            status=FriendTable.FriendshipStatus.PENDING,
        )
        return friendrequest
