from datetime import timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework.test import APIRequestFactory

from api.admin import WorkoutRecordAdmin

User = get_user_model()


class TestHelperFuncs(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )  # type: ignore

        self.application = Application.objects.create(
            name="TestApp",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
        )

        self.token = AccessToken.objects.create(
            user=self.user,
            token="valid_token_123",
            application=self.application,
            expires=now() + timedelta(days=1),
        )

        self.factory = APIRequestFactory()

    def test_user_activity_admin_list_display(self):
        self.assertEqual(
            WorkoutRecordAdmin.list_display,
            [
                "workoutid",
                "lastUpdate",
                "userid",
                "calories",
                "steps",
                "creationDate",
                "activityid",
            ],
        )

    def test_user_activity_admin_ordering(self):
        self.assertEqual(WorkoutRecordAdmin.ordering, ["lastUpdate"])

    def test_user_activity_admin_readonly_fields(self):
        self.assertEqual(WorkoutRecordAdmin.readonly_fields, ["creationDate"])
