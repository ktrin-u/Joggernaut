from datetime import timedelta

from django.test import TestCase
from django.urls import reverse
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient

from api.models import GameCharacter, GameSave, User


class TestGameCharacterView(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create a test user
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171234567",
            firstname="Test",
            lastname="User",
            password="TestPassword123",
        )

        # Create an OAuth2 application
        self.application = Application.objects.create(
            name="Test Application",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
            user=self.user,
        )

        # Create an access token with the required scopes
        self.access_token = AccessToken.objects.create(
            user=self.user,
            scope="read write",
            expires=now() + timedelta(days=1),
            token="test-access-token",
            application=self.application,
        )

        # Authenticate the client with the access token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token.token}")

        # Create a game save for the user
        self.game_save = GameSave.objects.create(owner=self.user)

        # Create game characters
        self.character1 = GameCharacter.objects.create(
            gamesave_id=self.game_save,
            name="Character1",
            color="RED",
            type="KNIGHT",
            health=10,
            speed=5,
            strength=7,
            stamina=8,
        )
        self.character2 = GameCharacter.objects.create(
            gamesave_id=self.game_save,
            name="Character2",
            color="BLUE",
            type="ARCHER",
            health=8,
            speed=7,
            strength=5,
            stamina=6,
        )

        # Define the URL for the game character endpoint
        self.character_url = reverse("get characters")

    def test_get_game_characters(self):
        """Test retrieving all game characters for the user."""
        response = self.client.get(self.character_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("characters", response.json())
        self.assertEqual(len(response.json()["characters"]), 2)

    def test_post_game_character_valid(self):
        """Test creating a new game character with valid data."""
        data = {
            "name": "NewCharacter",
            "color": "YELLOW",
            "type": "PAWN",
            "health": 5,
            "speed": 5,
            "strength": 5,
            "stamina": 5,
        }
        response = self.client.post(self.character_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            f"PASS: character {data['name']} for user {self.user.email} has been created",
        )

    ## def test_delete_game_character_valid(self):
    ##   """Test deleting an existing game character."""
    ##  response = self.client.delete(self.character_url, {"id": self.character1.id}, format="json")
    #  self.assertEqual(response.status_code, status.HTTP_200_OK)
    #   self.assertIn("msg", response.json())
    #   self.assertEqual(
    #       response.json()["msg"],
    #       f"PASS: character {self.character1.name} has been deleted.",
    #    )
    #    self.assertEqual(GameCharacter.objects.filter(id=self.character1.id).count(), 0)
    # need to fix

    def test_patch_game_character_valid(self):
        """Test updating an existing game character with valid data."""
        data = {
            "id": self.character1.id,
            "name": "UpdatedCharacter",
            "health": 15,
        }
        response = self.client.patch(self.character_url, data)
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            f"PASS: successfully updated character {self.character1.id}",
        )

        # Assert that the character was updated
        self.character1.refresh_from_db()
        self.assertEqual(self.character1.name, "UpdatedCharacter")
        self.assertEqual(self.character1.health, 15)

    def test_patch_game_character_not_found(self):
        """Test updating a non-existent game character."""
        data = {
            "id": 9999,  # Non-existent ID
            "name": "NonExistentCharacter",
        }
        response = self.client.patch(self.character_url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            "FAIL: Gamecharacter 9999 for user testuser@email.com is NOT FOUND",
        )
