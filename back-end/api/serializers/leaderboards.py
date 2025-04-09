from rest_framework import serializers
from enum import StrEnum

from api.models import GameSave


class LeaderboardCategories(StrEnum):
    STEPS = "steps"
    ATTEMPTS = "attempts"

class LeaderboardTimeframe(StrEnum):
    DAYS = "D"
    WEEKS = "W"
    MONTHS = "M"

class GetLeaderboardRequestSerializer(serializers.Serializer):
    top_n = serializers.IntegerField(min_value=5,default=5)
    category = serializers.ChoiceField(
        allow_blank=True,
        choices=[
            (category, category.value) for category in LeaderboardCategories
        ]
    )
    # timeframe = serializers.ChoiceField(
    #     default=LeaderboardTimeframe.DAYS
    #     choices=[
    #         (category, category.value) for category in LeaderboardTimeframe
    #     ]
    # )


class LifetimeAttemptsLeaderboardSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = GameSave
        fields = ["attempts_lifetime"]
        extra_kwargs = {
            "owner": {
                "source": "user.firstname"
            }
        }
