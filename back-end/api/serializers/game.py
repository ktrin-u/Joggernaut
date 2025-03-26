from rest_framework import serializers

from api.models import GameCharacter, GameSave


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
