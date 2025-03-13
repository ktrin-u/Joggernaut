import api.models as custom_models
from rest_framework import serializers
from django.core.exceptions import ValidationError


class NewWorkoutRecordRequestSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = custom_models.WorkoutRecord
        fields = ["calories", "steps"]


class NewWorkoutRecordSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = custom_models.WorkoutRecord
        fields = ["userid", "calories", "steps"]


class GetWorkoutRecordSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = custom_models.WorkoutRecord
        fields = ["workoutid", "calories", "steps", "lastUpdate", "creationDate"]


class UpdateWorkoutRecordSerializer(serializers.ModelSerializer):
    workoutid = serializers.IntegerField(min_value=1, required=True)

    class Meta:  # type: ignore
        model = custom_models.WorkoutRecord
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
