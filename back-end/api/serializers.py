from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import UserManager
from django.contrib.auth.password_validation import validate_password

UserModel = get_user_model()


class RegisterFormSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = get_user_model()
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