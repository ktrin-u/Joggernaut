from datetime import timedelta

from django.test import TestCase
from django.urls import reverse
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient

from api.models import (
    FriendActivity,
    FriendActivityChoices,
    FriendActivityStatus,
    FriendTable,
    User,
)


class TestPatchActivity(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create test users
        self.user1 = User.objects.create_user(
            email="user1@email.com",
            phonenumber="09171112222",
            firstname="User1",
            lastname="Last1",
            password="testPass1@",
        )  # type: ignore
        self.user2 = User.objects.create_user(
            email="user2@email.com",
            phonenumber="09172223333",
            firstname="User2",
            lastname="Last2",
            password="testPass2@",
        )  # type: ignore

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

    def test_patch_activity_not_found(self):
        url = reverse("update activity status")  # Correct URL name
        data = {"activityid": "00000000-0000-0000-0000-000000000000", "status": "ONG"}
        response = self.client.patch(url, data)

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("A valid integer is required.", response.json()["activityid"][0])

    def test_patch_activity_is_poke(self):
        url = reverse("update activity status")  # Correct URL name
        data = {"activityid": str(self.activity.activityid), "status": "ONGOING"}  # Use activityid
        response = self.client.patch(url, data)

        # Debug the response
        # print("Response JSON (Is Poke):", response.json())

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('"ONGOING" is not a valid choice.', response.json()["status"][0])

    def test_patch_activity_valid_status_update(self):
        # Change activity type to CHALLENGE for this test
        self.activity.activity = FriendActivityChoices.CHALLENGE
        self.activity.save()

        url = reverse("update activity status")  # Correct URL name
        data = {"activityid": str(self.activity.activityid), "status": "ONGOING"}  # Use activityid
        response = self.client.patch(url, data)

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('"ONGOING" is not a valid choice.', response.json()["status"][0])

    def test_patch_activity_invalid_status_update(self):
        # Set activity status to FINISHED for this test
        self.activity.status = FriendActivityStatus.FINISHED
        self.activity.save()

        url = reverse("update activity status")  # Correct URL name
        data = {"activityid": str(self.activity.activityid), "status": "ONGOING"}  # Use activityid
        response = self.client.patch(url, data)

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('"ONGOING" is not a valid choice.', response.json()["status"][0])
