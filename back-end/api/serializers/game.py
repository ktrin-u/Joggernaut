from drf_spectacular.utils import OpenApiExample, extend_schema_serializer
from rest_framework import serializers

from api.models import GameCharacter, GameCharacterClass, GameCharacterColor, GameSave


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
                        "color": "RED",
                        "class": "PAWN",
                        "health": 1,
                        "speed": 1,
                        "strength": 1,
                        "stamina": 1,
                    },
                    {
                        "id": 45,
                        "selected": "false",
                        "name": "string",
                        "color": "YELLOW",
                        "class": "KNIGHT",
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
            "color",
            "type",
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
            "color": {"default": GameCharacterColor.RED},
            "type": {"default": GameCharacterClass.PAWN},
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
        fields = ["name", "color", "type", "health", "speed", "strength", "stamina"]

    def validate_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Name cannot be empty.")
        return value


class TargetCharacterSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(min_value=1, required=True)

    class Meta:  # type: ignore
        model = GameCharacter
        fields = ["id"]


@extend_schema_serializer(
    examples=[
        OpenApiExample(
            name="select char",
            value={
                "selected": None,
            },
            request_only=True,
        )
    ]
)
class EditCharacterSerializer(serializers.ModelSerializer):
    class Meta:  # type: ignore
        model = GameCharacter
        fields = [
            "id",
            "selected",
            "name",
            "color",
            "type",
            "health",
            "speed",
            "strength",
            "stamina",
        ]

        DEFAULT = {"required": False, "default": ""}

        extra_kwargs = {
            "id": {
                "required": True,
                "read_only": False,
                "min_value": 1,
                "help_text": "id of the character to be updated",
            },
            "name": {"required": False, "default": "", "max_length": 32},
            "selected": {"required": False, "default": "", "allow_null": True},
            "color": DEFAULT,
            "type": DEFAULT,
            "health": DEFAULT,
            "speed": DEFAULT,
            "strength": DEFAULT,
            "stamina": DEFAULT,
        }

    def validate(self, attrs):
        return attrs

    def update(self, instance: GameCharacter, validated_data) -> GameCharacter:
        if self.validated_data.get("selected", False):
            instance.select()
        instance.name = validated_data.get("name", instance.name)
        instance.color = validated_data.get("color", instance.color)
        instance.type = validated_data.get("type", instance.type)
        instance.health = validated_data.get("health", instance.health)
        instance.speed = validated_data.get("speed", instance.speed)
        instance.strength = validated_data.get("strength", instance.strength)
        instance.stamina = validated_data.get("stamina", instance.stamina)
        instance.save()
        return instance
