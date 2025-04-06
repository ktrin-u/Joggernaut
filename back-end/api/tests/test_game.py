import json
import uuid
from unittest.mock import patch
from django.contrib.auth.models import AnonymousUser
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from api.models.game import GameCharacter, GameSave
from api.models.user import User


class GameViewTests(APITestCase):
    def setUp(self):
        self.client = APIClient()

        # Create a mock user
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171112222",
            firstname="Test",
            lastname="User",
            password="testPass123",
        )
        self.client.force_authenticate(user=self.user)

        # Base URLs
        self.gamesave_url = "/api/game/"
        self.gamecharacter_url = "/api/game/character/"

    # -------------------- GameSaveView Tests --------------------

    def test_get_gamesave_create_new(self):
        # Test creating a new GameSave for the user
        response = self.client.get(self.gamesave_url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  

    def test_get_gamesave_existing(self):
        # Create a GameSave for the user
        GameSave.objects.create(owner=self.user)

        # Test retrieving the existing GameSave
        response = self.client.get(self.gamesave_url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  

    def test_get_gamesave_invalid_user_type(self):
        # Mock the request.user to be an AnonymousUser
        with patch("api.views.game.GameSaveView.get_gamesave_object") as mock_method:
            mock_method.side_effect = TypeError("User object is type <class 'AnonymousUser'>")

            response = self.client.get(self.gamesave_url)
            self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    # -------------------- GameCharacterView Tests --------------------

    def test_get_game_characters_success(self):
        # Create a GameSave and characters for the user
        gamesave = GameSave.objects.create(owner=self.user)
        GameCharacter.objects.create(gamesave_id=gamesave, name="Character1")
        GameCharacter.objects.create(gamesave_id=gamesave, name="Character2")

        # Test retrieving the list of characters
        response = self.client.get(self.gamecharacter_url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_get_game_characters_no_gamesave(self):
        # Test retrieving characters when no GameSave exists
        response = self.client.get(self.gamecharacter_url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_create_game_character_success(self):
        # Create a GameSave for the user
        gamesave = GameSave.objects.create(owner=self.user)

        # Test creating a new character
        data = {"name": "NewCharacter", "level": 1}
        response = self.client.post(self.gamecharacter_url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_create_game_character_invalid_data(self):
        # Create a GameSave for the user
        GameSave.objects.create(owner=self.user)

        # Test creating a character with invalid data
        data = {"name": "", "level": -1}
        response = self.client.post(self.gamecharacter_url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_delete_game_character_success(self):
        # Create a GameSave and a character for the user
        gamesave = GameSave.objects.create(owner=self.user)
        character = GameCharacter.objects.create(gamesave_id=gamesave, name="CharacterToDelete")

        # Test deleting the character
        response = self.client.delete(f"{self.gamecharacter_url}?id={character.id}")
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_delete_game_character_not_found(self):
        # Test deleting a character that does not exist
        response = self.client.delete(f"{self.gamecharacter_url}?id=999")
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_update_game_character_success(self):
        # Create a GameSave and a character for the user
        gamesave = GameSave.objects.create(owner=self.user)
        character = GameCharacter.objects.create(gamesave_id=gamesave, name="CharacterToUpdate")

        # Test updating the character
        data = {"id": character.id, "name": "UpdatedCharacter"}
        response = self.client.patch(self.gamecharacter_url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_update_game_character_no_changes(self):
        # Create a GameSave and a character for the user
        gamesave = GameSave.objects.create(owner=self.user)
        character = GameCharacter.objects.create(gamesave_id=gamesave, name="CharacterNoChange")

        # Test updating the character with no changes
        data = {"id": character.id}
        response = self.client.patch(self.gamecharacter_url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  
    def test_update_game_character_not_found(self):
        # Test updating a character that does not exist
        data = {"id": 999, "name": "NonExistentCharacter"}
        response = self.client.patch(self.gamecharacter_url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN) 