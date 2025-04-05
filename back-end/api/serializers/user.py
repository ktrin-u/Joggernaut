from typing import Any

from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from rest_framework import serializers

from api.models import User, UserManager, UserProfiles


class RegisterFormSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = User
        fields = ["firstname", "lastname", "email", "phonenumber", "password"]
        extra_kwargs = {"password": {"write_only": True}}

    def validate_password(self, value):
        validate_password(value)
        return value

    def create(self, validated_data):
        manager: UserManager = User.objects  # type:ignore
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
    new_password = serializers.CharField(
        write_only=True, required=True, validators=[validate_password]
    )
    confirm_password = serializers.CharField(write_only=True, required=True)

    class Meta:  # type: ignore
        model = User

    def validate(self, attrs) -> dict[str, Any]:
        if attrs["new_password"] != attrs["confirm_password"]:
            raise ValidationError(
                {
                    "new_password": "match failed",
                    "confirm_password": "match failed",
                }
            )
        return attrs

    def update(self, instance, validated_data):
        assert isinstance(instance, User)
        new_password = validated_data.get("new_password", None)
        if new_password is None:
            return instance
        instance.set_password(new_password)
        instance.save()
        return instance


class UserModelSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = User
        fields = [
            "userid",
            "email",
            "firstname",
            "lastname",
            "phonenumber",
            "joindate",
            "last_login",
            "is_active",
            "is_staff",
        ]


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
        model = User


class UpdateUserPermissionsSerializer(serializers.Serializer):
    userid = serializers.UUIDField(required=False)
    email = serializers.EmailField(required=False)


class PublicUserSerializer(serializers.ModelSerializer):
    firstname = serializers.CharField(source="userid.firstname")

    class Meta:  # type: ignore
        model = UserProfiles
        fields = ["userid", "firstname", "accountname", "gender"]


class PublicUserResponseSerializer(serializers.Serializer):
    users = serializers.ListField(allow_empty=True)

    def validate_users(self, value):
        if not all(isinstance(x, UserProfiles) for x in value):
            raise ValidationError({"users": "list contents must be of type UserProfile"})
        return value


class UserIdFilterSerializer(serializers.ModelSerializer):
    userid = serializers.UUIDField()

    class Meta:  # type: ignore
        model = User
        fields = ["userid"]
