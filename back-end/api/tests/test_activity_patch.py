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

        # Create activities
        self.activity_poke = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
            status=FriendActivityStatus.PENDING,
            durationSecs=3600,
        )
        self.activity_challenge = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.CHALLENGE,
            status=FriendActivityStatus.PENDING,
            durationSecs=3600,
        )

        # Define the URL for the activity endpoint
        self.activity_url = reverse("update activity status")

    def test_patch_activity_successful_update(self):
        """Test successfully updating an activity's status."""
        data = {
            "activityid": self.activity_challenge.activityid,
            "status": FriendActivityStatus.ONGOING,
        }
        response = self.client.patch(self.activity_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            f"PASS: activity {self.activity_challenge.activityid} status is set to {FriendActivityStatus.ONGOING}",
        )

        # Assert that the activity's status was updated
        self.activity_challenge.refresh_from_db()
        self.assertEqual(self.activity_challenge.status, FriendActivityStatus.ONGOING)

    def test_patch_activity_no_action_for_poke(self):
        """Test patching a POKE activity results in no action."""
        data = {
            "activityid": self.activity_poke.activityid,
            "status": FriendActivityStatus.ONGOING,
        }
        response = self.client.patch(self.activity_url, data)
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            f"PASS: activity {self.activity_poke.activityid} is POK so no action taken",
        )

    def test_patch_activity_invalid_status_update(self):
        """Test patching an activity with an invalid status update."""
        # Set the activity's status to FINISHED (a valid status)
        self.activity_challenge.status = FriendActivityStatus.FINISHED
        self.activity_challenge.save()

        data = {
            "activityid": self.activity_challenge.activityid,
            "status": FriendActivityStatus.ONGOING,
        }
        response = self.client.patch(self.activity_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            f"FAIL: activity {self.activity_challenge.activityid} cannot be changed due to status {FriendActivityStatus.ONGOING}.",
        )
    def test_patch_activity_not_found(self):
        """Test patching a non-existent activity."""
        data = {
            "activityid": 9999,  # Non-existent activity ID
            "status": FriendActivityStatus.ONGOING,
        }
        response = self.client.patch(self.activity_url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertIn("msg", response.json())
        self.assertEqual(
            response.json()["msg"],
            "FAIL: activity 9999 is NOT FOUND",
        )

    def test_patch_activity_invalid_data(self):
        """Test patching an activity with invalid data."""
        data = {
            "activityid": "",  # Invalid activity ID (empty string)
            "status": "INVALID_STATUS",  # Invalid status
        }
        response = self.client.patch(self.activity_url, data, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("activityid", response.json())
        self.assertIn("status", response.json())