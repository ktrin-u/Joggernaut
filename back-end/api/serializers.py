from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import UserManager, UserProfiles
from django.contrib.auth.password_validation import validate_password

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
