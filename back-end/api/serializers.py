from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.contrib.auth import get_user_model
from .models import UserManager, UserProfiles
from django.contrib.auth.password_validation import validate_password
from typing import Any

UserModel = get_user_model()


class RegisterFormSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = UserModel
        fields = ['firstname', 'lastname', 'email', 'phonenumber', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate_password(self, value):
        validate_password(value)
        return value

    def create(self, validated_data):
        manager: UserManager = UserModel.objects  # type:ignore
        new_user = manager.create_user(
            email=validated_data["email"],
            firstname=validated_data["firstname"],
            lastname=validated_data["lastname"],
            password=validated_data["password"],
            phonenumber=validated_data["phonenumber"],
        )
        new_user.set_password(validated_data["password"])
        new_user.save()

        return new_user


class UpdateUserPasswordSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    confirm_password = serializers.CharField(write_only=True, required=True)

    class Meta:  # type: ignore
        model = UserModel

    def validate(self, attrs) -> Any:
        if attrs["new_password"] != attrs["confirm_password"]:
            raise ValidationError(
                {
                    "new_password": "match failed",
                    "confirm_password": "match failed",
                }
            )
        return attrs

    def update(self, instance, validated_data):
        assert isinstance(instance, UserModel)
        new_password = validated_data.get("new_password", None)
        if new_password is None:
            return instance
        instance.set_password(new_password)
        instance.save()
        return instance


class UserProfileFormSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = UserProfiles
        fields = ['userid', 'accountname', 'dateofbirth', 'gender', 'address', 'height_cm', 'weight_kg']

    def create(self, validated_data) -> UserProfiles:
        profile_manager = UserProfiles.objects
        new_profile, created = profile_manager.update_or_create(
            userid=validated_data["userid"],
            accountname=validated_data["accountname"],
            dateofbirth=validated_data["dateofbirth"],
            gender=validated_data["gender"],
            address=validated_data["address"],
            height_cm=validated_data["height_cm"],
            weight_kg=validated_data["weight_kg"]
        )
        if created:
            new_profile.save()
        return new_profile


class UserModelSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = UserModel
        fields = ["userid", "email", "firstname", "lastname", "phonenumber", "joindate", "last_login", "is_active", "is_staff"]


class UserDeleteSerializer(serializers.Serializer):
    delete = serializers.BooleanField()
    confirm_delete = serializers.BooleanField()

    def validate(self, attrs):
        delete = attrs["delete"]
        confirm_delete = attrs["confirm_delete"]

        if not delete:
            raise ValidationError({"delete": "consent not received"})

        if delete != confirm_delete:
            raise ValidationError({"confirm_delete": "conflicting delete confirmation"})

        return attrs

    class Meta:
        model = UserModel


class UpdateUserPermissionsSerializer(serializers.Serializer):
    userid = serializers.UUIDField(required=False)
    email = serializers.EmailField(required=False)


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
