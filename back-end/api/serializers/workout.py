from django.core.exceptions import ValidationError
from rest_framework import serializers

from api.models import WorkoutRecord


class NewWorkoutRecordSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = WorkoutRecord
        fields = ["userid", "calories", "steps"]
        extra_kwargs = {
            "userid": {
                "allow_empty": True,
                "default": "",
                "help_text": "Defaults to userid of authenticated user if left blank.",
            },
            "calories": {"min_value": 0, "default": 0},
            "steps": {"min_value": 0, "default": 0},
        }

    def create(self, validated_data) -> WorkoutRecord:
        return WorkoutRecord.objects.create(**validated_data)


class WorkoutRecordSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = WorkoutRecord
        fields = [
            "workoutid",
            "activityid",
            "calories",
            "steps",
            "lastUpdate",
            "userid",
            "creationDate",
        ]


class UpdateWorkoutRecordSerializer(serializers.ModelSerializer):
    workoutid = serializers.IntegerField(min_value=1, required=True)

    class Meta:  # type: ignore
        model = WorkoutRecord
        fields = ["workoutid", "calories", "steps"]

    def validate(self, attrs):
        if not attrs["calories"] and not attrs["steps"]:
            raise ValidationError(
                {
                    "calories": "at least one of the two must be non zero",
                    "steps": "at least one of the two must be non zero",
                }
            )
        return attrs
