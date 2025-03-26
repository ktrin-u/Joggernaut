from drf_spectacular.utils import OpenApiExample, extend_schema_serializer
from rest_framework import serializers

from api.models import GameCharacter, GameSave


@extend_schema_serializer(
    examples=[
        OpenApiExample(
            name="has characters",
            value={
                "characters": [
                    {
                        "id": 2,
                        "selected": "false",
                        "name": "string",
                        "color_hex": "#ffffff",
                        "health": 1,
                        "speed": 1,
                        "strength": 1,
                        "stamina": 1,
                    },
                    {
                        "id": 45,
                        "selected": "false",
                        "name": "string",
                        "color_hex": "#ffffff",
                        "health": 1,
                        "speed": 1,
                        "strength": 1,
                        "stamina": 1,
                    },
                ]
            },
        ),
        OpenApiExample(name="no characters", value={"characters": []}),
    ]
)
class GameCharacterSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = GameCharacter
        fields = [
            "id",
            "selected",
            "name",
            "color_hex",
            "health",
            "speed",
            "strength",
            "stamina",
        ]

        default_stat_kwargs = {
            "min_value": 1,
            "default": 1,
        }
        extra_kwargs = {
            "id": default_stat_kwargs,
            "color_hex": {"default": "#ffffff"},
            "health": default_stat_kwargs,
            "speed": default_stat_kwargs,
            "strength": default_stat_kwargs,
            "stamina": default_stat_kwargs,
        }


class CreateGameSaveSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = GameSave
        fields = ["owner"]


class CreateGameCharacterSerializer(GameCharacterSerializer):
    class Meta(GameCharacterSerializer.Meta):
        fields = ["name", "color_hex", "health", "speed", "strength", "stamina"]


class TargetCharacterSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(min_value=1, required=True)

    class Meta:  # type: ignore
        model = GameCharacter
        fields = ["id"]
