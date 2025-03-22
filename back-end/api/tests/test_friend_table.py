from django.test import TestCase
from api.models import User, FriendTable
from django.core.exceptions import ValidationError


class TestFriendTable(TestCase):
    def setUp(self):
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

    def test_friendship_creation(self):
        friendship = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.PENDING,  
        )
        self.assertEqual(friendship.fromUserid, self.user1)
        self.assertEqual(friendship.toUserid, self.user2)
        self.assertEqual(friendship.status, FriendTable.FriendshipStatus.PENDING)  

    def test_self_referencing_friendship(self):
        with self.assertRaises(ValidationError):
            self_referencing_friendship = FriendTable(
                fromUserid=self.user1,
                toUserid=self.user1,
                status=FriendTable.FriendshipStatus.PENDING,
            )
            self_referencing_friendship.full_clean()  # Trigger validation

    def test_reject_friend_request(self):
        friendship = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.PENDING,
        )
        friendship.status = FriendTable.FriendshipStatus.REJECTED
        friendship.save()  # Should not raise ValidationError
        self.assertEqual(friendship.status, FriendTable.FriendshipStatus.REJECTED)
    def test_accept_friend_request(self):
        friendship = FriendTable.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            status=FriendTable.FriendshipStatus.PENDING,
        )
        friendship.status = FriendTable.FriendshipStatus.ACCEPTED
        friendship.save()  # Should not raise ValidationError
        self.assertEqual(friendship.status, FriendTable.FriendshipStatus.ACCEPTED)