from django.test import TestCase
from api.models import User, FriendTable
from api.serializers.friends import (
    ToUserIdSerializer,
    FromUserIdSerializer,
    FriendTableSerializer,
    FriendsListResponseSerializer,
    PendingFriendsListResponseSerializer,
    CreateFriendSerializer,
)
from rest_framework.exceptions import ErrorDetail


class TestFriendSerializers(TestCase):
    def setUp(self):
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

        # Create a FriendTable instance
        self.friend = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.PENDING,
        )

    def test_to_user_id_serializer(self):
        serializer = ToUserIdSerializer(instance=self.friend)
        self.assertEqual(serializer.data, {"toUserid": self.user2.userid})

    def test_from_user_id_serializer(self):
        serializer = FromUserIdSerializer(instance=self.friend)
        self.assertEqual(serializer.data, {"fromUserid": self.user1.userid})


    def test_friends_list_response_serializer_valid(self):
        serializer = FriendsListResponseSerializer(data={"friends": [self.friend]})
        self.assertTrue(serializer.is_valid())

    def test_friends_list_response_serializer_invalid(self):
        serializer = FriendsListResponseSerializer(data={"friends": ["invalid"]})
        self.assertFalse(serializer.is_valid())
        self.assertEqual(
            serializer.errors,
            {"friends": {"friends": [ErrorDetail(string="list contents must be of type FriendTable", code="invalid")]}}  # noqa
        )

    def test_pending_friends_list_response_serializer_valid(self):
        serializer = PendingFriendsListResponseSerializer(
            data={"sent": [self.friend], "received": []}
        )
        self.assertTrue(serializer.is_valid())

    def test_pending_friends_list_response_serializer_invalid_sent(self):
        serializer = PendingFriendsListResponseSerializer(
            data={"sent": ["invalid"], "received": []}
        )
        self.assertFalse(serializer.is_valid())
        self.assertEqual(
            serializer.errors,
            {"sent": {"sent": [ErrorDetail(string="list contents must be of type FriendTable", code="invalid")]}}  # noqa
        )

    def test_pending_friends_list_response_serializer_invalid_received(self):
        serializer = PendingFriendsListResponseSerializer(
            data={"sent": [], "received": ["invalid"]}
        )
        self.assertFalse(serializer.is_valid())
        self.assertEqual(
            serializer.errors,
            {"received": {"received": [ErrorDetail(string="list contents must be of type FriendTable", code="invalid")]}}  # noqa
        )