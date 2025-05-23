from django.db.utils import IntegrityError
from django.test import TestCase
from django.utils.timezone import now, timedelta

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
        with self.assertRaises(IntegrityError):
            self_referencing_activity = FriendActivity.objects.create(
                fromUserid=self.user1,
                toUserid=self.user1,
                activity=FriendActivityChoices.POKE,
            )
            self_referencing_activity.full_clean()

    # Removed due to deprecation of the functions
    # def test_accept_activity(self):
    #     activity = FriendActivity.objects.create(
    #         fromUserid=self.user1,
    #         toUserid=self.user2,
    #         activity=FriendActivityChoices.POKE,
    #     )
    #     activity.accept_activity()
    #     self.assertEqual(activity.status, FriendActivityStatus.ACCEPT)
    #     self.assertIsNotNone(activity.statusDate)

    # def test_accept_activity_when_expired(self):
    #     activity = FriendActivity.objects.create(
    #         fromUserid=self.user1,
    #         toUserid=self.user2,
    #         activity=FriendActivityChoices.POKE,
    #     )
    #     activity.creationDate = now() - timedelta(seconds=activity.durationSecs + 1)
    #     activity.save()
    #     self.assertFalse(activity.accept_activity())

    # def test_reject_activity(self):
    #     activity = FriendActivity.objects.create(
    #         fromUserid=self.user1,
    #         toUserid=self.user2,
    #         activity=FriendActivityChoices.POKE,
    #     )
    #     self.assertTrue(activity.reject_activity())
    #     self.assertEqual(activity.status, FriendActivityStatus.REJECT)
    #     self.assertIsNotNone(activity.statusDate)

    #     activity.status = FriendActivityStatus.PENDING
    #     activity.creationDate = now() - timedelta(seconds=activity.durationSecs + 1)  # set expired
    #     activity.save()
    #     self.assertFalse(activity.reject_activity())

    # def test_cancel_activity(self):
    #     activity = FriendActivity.objects.create(
    #         fromUserid=self.user1,
    #         toUserid=self.user2,
    #         activity=FriendActivityChoices.POKE,
    #     )
    #     self.assertTrue(activity.cancel_activity())
    #     self.assertEqual(activity.status, FriendActivityStatus.CANCEL)
    #     self.assertIsNotNone(activity.statusDate)

    #     activity.status = FriendActivityStatus.PENDING
    #     activity.creationDate = now() - timedelta(seconds=activity.durationSecs + 1)
    #     activity.save()
    #     self.assertFalse(activity.cancel_activity())

    def test_expired_property(self):
        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
            durationSecs=0,
        )
        self.assertFalse(activity.expired)

        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.POKE,
            durationSecs=3600,
        )
        activity.creationDate = now() - timedelta(seconds=activity.durationSecs + 1)
        activity.save()
        self.assertTrue(activity.expired)
        self.assertEqual(activity.status, FriendActivityStatus.EXPIRED)
        self.assertIsNotNone(activity.statusDate)

    def test_deadline_property_none(self):
        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.CHALLENGE,
            status=FriendActivityStatus.PENDING,
            statusDate=now(),
            durationSecs=0,
        )
        self.assertEqual(activity.deadline, None)

        activity.update_status(FriendActivityStatus.FINISHED)
        self.assertEqual(activity.deadline, None)

    def test_deadline_property_datetime(self):
        activity = FriendActivity.objects.create(
            fromUserid=self.user1,
            toUserid=self.user2,
            activity=FriendActivityChoices.CHALLENGE,
            status=FriendActivityStatus.PENDING,
            durationSecs=5,
        )
        duration = timedelta(seconds=activity.durationSecs)
        valid_deadline = activity.creationDate + duration
        self.assertEqual(activity.deadline, valid_deadline)

        activity.update_status(FriendActivityStatus.ONGOING)

        valid_deadline = activity.statusDate + duration  # type: ignore
        self.assertEqual(activity.deadline, valid_deadline)
