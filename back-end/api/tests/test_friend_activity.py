from django.core.exceptions import ValidationError
from django.test import TestCase

from api.models import FriendActivity, FriendActivityChoices, FriendActivityStatus, User


class TestFriendActivity(TestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(  # type: ignore
            email="user1@email.com",
            phonenumber="09171112222",
            firstname="User1",
            lastname="Last1",
            password="testPass1@",
        )
        self.user2 = User.objects.create_user(  # type: ignore
            email="user2@email.com",
            phonenumber="09172223333",
            firstname="User2",
            lastname="Last2",
            password="testPass2@",
        )

    def test_activity_creation(self):
        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        self.assertEqual(activity.fromUserid, self.user1)
        self.assertEqual(activity.toUserid, self.user2)
        self.assertEqual(activity.activity, FriendActivityChoices.POKE)

    def test_self_referencing_activity(self):
        with self.assertRaises(ValidationError):
            self_referencing_activity = FriendActivity(
                fromUserid=self.user1,
                toUserid=self.user1,
                activity=FriendActivityChoices.POKE,
            )
            self_referencing_activity.full_clean()  # Trigger validation

    def test_accept_activity(self):
        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        activity.accept_activity()
        self.assertEqual(activity.status, FriendActivityStatus.ACCEPT)
        self.assertIsNotNone(activity.statusDate)

    def test_duplicate_activity_creation(self):
        FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        # Creating the same activity again should succeed unless explicitly restricted
        duplicate_activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        self.assertEqual(duplicate_activity.fromUserid, self.user1)
        self.assertEqual(duplicate_activity.toUserid, self.user2)
        self.assertEqual(duplicate_activity.activity, FriendActivityChoices.POKE)

    def test_activity_reverse_users(self):
        activity1 = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        activity2 = FriendActivity.objects.create(
            fromUserid=self.user2,
            toUserid=self.user1,
            activity=FriendActivityChoices.POKE,
        )
        self.assertNotEqual(activity1, activity2)

    def test_activity_with_different_activities(self):
        poke_activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
        )
        challenge_activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.CHALLENGE,
        )
        self.assertNotEqual(poke_activity.activity, challenge_activity.activity)
