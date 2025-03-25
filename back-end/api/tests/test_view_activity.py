from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from api.models import User, FriendTable, FriendActivity, FriendActivityStatus, FriendActivityChoices
from oauth2_provider.models import AccessToken, Application
from datetime import timedelta
from django.utils.timezone import now


class TestActivityViews(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create test users
        self.user1 = User.objects.create_user(
            email="user1@email.com",
            phonenumber="09171112222",
            firstname="User1",
            lastname="Last1",
            password="testPass1@",
        )
        self.user2 = User.objects.create_user(
            email="user2@email.com",
            phonenumber="09172223333",
            firstname="User2",
            lastname="Last2",
            password="testPass2@",
        )

        # Create an OAuth2 application
        self.application = Application.objects.create(
            name="Test Application",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
            user=self.user1,
        )

        # Create an access token with the required scopes
        self.access_token = AccessToken.objects.create(
            user=self.user1,
            scope="read write",
            expires=now() + timedelta(days=1),
            token="test-access-token",
            application=self.application,
        )

        # Authenticate the client with the access token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token.token}")

        # Create a friendship
        self.friendship = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.ACCEPTED,
        )

        # Create a pending activity
        self.activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
            status=FriendActivityStatus.PENDING,
            durationSecs=3600,
        )

    def test_get_friend_activity_view(self):
        url = reverse("get activities between user and friends")  # Correct URL name
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)

    def test_poke_friend_view_valid(self):
        url = reverse("poke a friend")  # Correct URL name
        data = {"toUserid": self.user2.userid, "durationSecs": 3600}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["msg"], "Poke Friend Activity entry successfully added to database")

    def test_poke_friend_view_not_friends(self):
        url = reverse("poke a friend")  # Correct URL name
        data = {"toUserid": "nonexistent-user-id", "durationSecs": 3600}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("toUserid", response.data)

    def test_challenge_friend_view_valid(self):
        url = reverse("challenge a friend")  # Correct URL name
        data = {"toUserid": self.user2.userid, "durationSecs": 3600}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["msg"], "Challenge Friend Activity entry successfully added to database")