from rest_framework import serializers


class MsgSerializer(serializers.Serializer):
    msg = serializers.CharField(default="message about what happened")


class TargetUserIdSerializer(serializers.Serializer):
    targetid = serializers.UUIDField()