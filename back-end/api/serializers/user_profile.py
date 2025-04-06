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
            "height_cm",
            "weight_kg",
        ]
        extra_kwargs = {"userid": {"validators": None}}

    def create(self, validated_data) -> UserProfiles:
        return UserProfiles.objects.create(
            userid=validated_data["userid"],
            accountname=validated_data["accountname"],
            dateofbirth=validated_data["dateofbirth"],
            gender=validated_data["gender"],
            height_cm=validated_data["height_cm"],
            weight_kg=validated_data["weight_kg"],
        )

    def update(self, instance, validated_data) -> UserProfiles:
        instance.accountname = validated_data.get("accountname", instance.accountname)
        instance.dateofbirth = validated_data.get("dateofbirth", instance.dateofbirth)
        instance.gender = validated_data.get("gender", instance.gender)
        instance.height_cm = validated_data.get("height_cm", instance.height_cm)
        instance.weight_kg = validated_data.get("weight_kg", instance.weight_kg)
        instance.save()
        return instance
