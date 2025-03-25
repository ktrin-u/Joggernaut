from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from api.models import User, FriendTable
from oauth2_provider.models import AccessToken, Application
from datetime import timedelta
from django.utils.timezone import now


class TestFriendsViews(TestCase):
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

        # Create a pending friend request
        self.friend_request = FriendTable.objects.create(
            fromUserid=self.user2,
            toUserid=self.user1,
            status=FriendTable.FriendshipStatus.PENDING,
        )

        # Create an accepted friend
        self.friend = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.ACCEPTED,
        )

    def test_send_friend_request_valid(self):
        url = reverse("send friend request")  # Correct URL name
        data = {"toUserid": self.user2.userid}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["msg"], "friend request entry successfully added to database")
        
    def test_send_friend_request_user_not_found(self):
        url = reverse("send friend request")  # Correct URL name
        data = {"toUserid": "non-existent-user-id"}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_accept_friend_request_valid(self):
        url = reverse("accept friend request")  # Correct URL name
        data = {"fromUserid": self.user2.userid}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["msg"],
            f"{self.user1.userid} has accepted {self.user2.userid}'s request",
        )

    def test_accept_friend_request_not_found(self):
        url = reverse("accept friend request")  # Correct URL name
        data = {"fromUserid": "non-existent-user-id"}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_reject_friend_request_valid(self):
        url = reverse("reject friend request")  # Correct URL name
        data = {"fromUserid": self.user2.userid}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["msg"],
            f"{self.user1.userid} has rejected {self.user2.userid}'s request. Friend Entry deleted.",
        )
    def test_reject_friend_request_not_found(self):
        url = reverse("reject friend request")  # Correct URL name
        data = {"fromUserid": "non-existent-user-id"}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_cancel_pending_friend_request_valid(self):
        url = reverse("cancel sent pending friend request")  # Correct URL name
        data = {"toUserid": self.user2.userid}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["msg"],
            f"pending request to {self.user2.userid} has been canceled",
        )

    def test_get_pending_friends(self):
        url = reverse("get pending friend list")  # Correct URL name
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("sent", response.data)
        self.assertIn("received", response.data)

    def test_get_friends(self):
        url = reverse("get friend list")  # Correct URL name
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("friends", response.data)

    def test_remove_friend_valid(self):
        url = reverse("unfriend a friend")  # Correct URL name
        data = {"targetid": self.user2.userid}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["msg"],
            f"successfully unfriended {self.user2.userid}",
        )

    def test_remove_friend_not_found(self):
        url = reverse("unfriend a friend")  # Correct URL name
        data = {"targetid": "non-existent-user-id"}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)