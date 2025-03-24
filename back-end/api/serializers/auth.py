from rest_framework import serializers


class ForgotPasswordEmailSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)


class ForgotPasswordTokenSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)
    token = serializers.CharField(required=True)