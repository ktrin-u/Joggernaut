from rest_framework import serializers


class TokenSerializer(serializers.Serializer):
    username = serializers.CharField(default="email")
    password = serializers.CharField(default="raw_password")
    grant_type = serializers.CharField(default="password")
    Scope = serializers.CharField(default="read write")
    client_id = serializers.CharField(default="MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")


class TokenResponseSerializer(serializers.Serializer):
    access_token = serializers.CharField(default="MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
    token_type = serializers.CharField(default="Bearer")
    expires_in = serializers.IntegerField(default="3600")
    refresh_token = serializers.CharField(default="IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk")
    scope = serializers.CharField(default="")


class RevokeTokenSerializer(serializers.Serializer):
    token = serializers.CharField(default="MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3")
    client_id = serializers.CharField(default="AAdjk4dlE7ssgbacPU8n4PeaQ1QYyqydhT2mPyyPi")
