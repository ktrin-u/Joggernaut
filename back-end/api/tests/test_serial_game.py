from django.test import TestCase

from api.models import GameCharacter, GameCharacterClass, GameCharacterColor, GameSave, User
from api.serializers.game import EditCharacterSerializer


class TestEditCharacterSerializer(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(  # type: ignore
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )
        self.gamesave = GameSave.objects.create(owner=self.user)
        # Create a mock GameCharacter instance
        self.character = GameCharacter.objects.create(
            gamesave_id=self.gamesave,
            name="TestCharacter",
            color=GameCharacterColor.RED,
            type=GameCharacterClass.PAWN,
            health=10,
            speed=5,
            strength=7,
            stamina=8,
        )

    def test_validate(self):
        # Test that the validate method returns the input data unchanged
        serializer = EditCharacterSerializer()
        input_data = {"name": "UpdatedName"}
        validated_data = serializer.validate(input_data)
        self.assertEqual(validated_data, input_data)

    def test_update_all_fields(self):
        # Test updating all fields of the GameCharacter instance
        validated_data = {
            "id": self.character.id,
            "name": "UpdatedName",
            "color": GameCharacterColor.YELLOW,
            "type": GameCharacterClass.KNIGHT,
            "health": 15,
            "speed": 10,
            "strength": 12,
            "stamina": 14,
        }
        serializer = EditCharacterSerializer(data=validated_data)
        self.assertTrue(serializer.is_valid())
        updated_character = serializer.update(self.character, serializer.validated_data)

        self.assertEqual(updated_character.name, "UpdatedName")
        self.assertEqual(updated_character.color, GameCharacterColor.YELLOW)
        self.assertEqual(updated_character.type, GameCharacterClass.KNIGHT)
        self.assertEqual(updated_character.health, 15)
        self.assertEqual(updated_character.speed, 10)
        self.assertEqual(updated_character.strength, 12)
        self.assertEqual(updated_character.stamina, 14)

    def test_update_partial_fields(self):
        # Test updating only some fields of the GameCharacter instance
        validated_data = {"name": "PartiallyUpdatedName", "health": 20}
        serializer = EditCharacterSerializer(data=validated_data, partial=True)
        self.assertTrue(serializer.is_valid())
        updated_character = serializer.update(self.character, serializer.validated_data)

        self.assertEqual(updated_character.name, "PartiallyUpdatedName")
        self.assertEqual(updated_character.health, 20)
        self.assertEqual(updated_character.speed, 5)  # Unchanged
        self.assertEqual(updated_character.strength, 7)  # Unchanged

    def test_update_selected_field(self):
        # Test updating the 'selected' field to True
        validated_data = {"selected": True}
        serializer = EditCharacterSerializer(data=validated_data, partial=True)
        self.assertTrue(serializer.is_valid())
        updated_character = serializer.update(self.character, serializer.validated_data)

        self.assertTrue(updated_character.selected)

    def test_update_invalid_data(self):
        # Test updating with invalid data (e.g., negative health)
        validated_data = {"health": -5}
        serializer = EditCharacterSerializer(data=validated_data, partial=True)
        self.assertFalse(serializer.is_valid())
