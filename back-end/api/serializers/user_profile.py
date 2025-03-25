from rest_framework import serializers

from api.models import UserProfiles


class UserProfileFormSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = UserProfiles
        fields = [
            "userid",
            "accountname",
            "dateofbirth",
            "gender",
            "address",
            "height_cm",
            "weight_kg",
        ]

    def create(self, validated_data) -> UserProfiles:
        profile_manager = UserProfiles.objects
        new_profile, created = profile_manager.update_or_create(
            userid=validated_data["userid"],
            accountname=validated_data["accountname"],
            dateofbirth=validated_data["dateofbirth"],
            gender=validated_data["gender"],
            address=validated_data["address"],
            height_cm=validated_data["height_cm"],
            weight_kg=validated_data["weight_kg"],
        )
        if created:
            new_profile.save()
        return new_profile
