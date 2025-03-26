import json
from datetime import timedelta
from uuid import uuid4 as random_userid

from django.test import TestCase
from django.urls import reverse
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient

from api.models import FriendTable, User


class TestFriendsViews(TestCase):
    def setUp(self):
        self.client = APIClient()
        self._user_count = 6
        # Create test users
        self.users = [
            User.objects.create_user(  # type: ignore
                email=f"user{num}@email.com",
                phonenumber=f"091711{num}2222",
                firstname=f"User{num}",
                lastname=f"Last{num}",
                password=f"testPass{num}@",
            )
            for num in range(self._user_count)
        ]
        # Create an OAuth2 application
        self.application = Application.objects.create(
            name="Test Application",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
            user=self.users[0],
        )

        # Create access tokens with the required scopes
        self.access_tokens = [
            AccessToken.objects.create(
                user=self.users[num],
                scope="read write",
                expires=now() + timedelta(days=1),
                token=f"test-access-token{num}",
                application=self.application,
            )
            for num in range(self._user_count)
        ]

        # Authenticate the client with the access token of user 0 by default
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_tokens[0]}")

        # Create a pending friend request
        self.friend_request = FriendTable.objects.create(
            fromUserid=self.users[2],
            toUserid=self.users[3],
            status=FriendTable.FriendshipStatus.PENDING,
        )

        # Create a pending friend request
        self.friend_request = FriendTable.objects.create(
            fromUserid=self.users[0],
            toUserid=self.users[2],
            status=FriendTable.FriendshipStatus.PENDING,
        )

    def _set_credentials(self, user_num: int):
        if isinstance(self.client, APIClient):
            self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_tokens[user_num]}")

    def test_send_friend_request_valid(self):
        user_num = 0
        self._set_credentials(user_num)
        url = reverse("send friend request")  # Correct URL name
        data = {"toUserid": str(self.users[user_num + 1].userid)}
        response = self.client.post(url, data)
        data = json.loads(response.content)
        self.assertEqual(data["msg"], "friend request entry successfully added to database")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_send_friend_request_user_not_found(self):
        url = reverse("send friend request")  # Correct URL name
        data = {"toUserid": str(random_userid())}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_accept_friend_request_valid(self):
        self._set_credentials(3)
        url = reverse("accept friend request")  # Correct URL name
        data = {"fromUserid": str(self.users[2].userid)}
        response = self.client.patch(url, data)
        data = json.loads(response.content)
        self.assertEqual(
            data["msg"],
            f"{self.users[3].userid} has accepted {self.users[2].userid}'s request",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_accept_friend_request_not_found(self):
        url = reverse("accept friend request")  # Correct URL name
        data = {"fromUserid": random_userid()}
        response = self.client.patch(url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_reject_friend_request_valid(self):
        self._set_credentials(2)
        url = reverse("reject friend request")  # Correct URL name
        data = {"fromUserid": str(self.users[0].userid)}
        response = self.client.patch(url, data)
        data = json.loads(response.content)
        self.assertEqual(
            data["msg"],
            f"{self.users[2].userid} has rejected {self.users[0].userid}'s request. Friend Entry deleted.",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_reject_friend_request_not_found(self):
        url = reverse("reject friend request")  # Correct URL name
        data = {"fromUserid": str(random_userid())}
        response = self.client.patch(url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_cancel_pending_friend_request_valid(self):
        # Create a pending friend request
        self.friend_request = FriendTable.objects.create(
            fromUserid=self.users[0],
            toUserid=self.users[3],
            status=FriendTable.FriendshipStatus.PENDING,
        )
        url = reverse("cancel sent pending friend request")  # Correct URL name
        data = {"toUserid": str(self.users[3].userid)}
        response = self.client.patch(url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            data["msg"],
            f"pending request to {self.users[3].userid} has been canceled",
        )

    def test_get_pending_friends(self):
        url = reverse("get pending friend list")  # Correct URL name
        response = self.client.get(url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("sent", data)
        self.assertIn("received", data)

    def test_get_friends(self):
        url = reverse("get friend list")  # Correct URL name
        response = self.client.get(url)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("friends", data)

    def test_remove_friend_valid(self):
        # Create an accepted friend
        self.friend = FriendTable.objects.create(
            fromUserid=self.users[0],
            toUserid=self.users[5],
            status=FriendTable.FriendshipStatus.ACCEPTED,
        )
        url = reverse("unfriend a friend")  # Correct URL name
        data = {"targetid": self.users[5].userid}
        response = self.client.post(url, data)
        data = json.loads(response.content)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            data["msg"],
            f"successfully unfriended {self.users[5].userid}",
        )

    def test_remove_friend_not_found(self):
        url = reverse("unfriend a friend")  # Correct URL name
        data = {"targetid": str(random_userid())}
        response = self.client.post(url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
