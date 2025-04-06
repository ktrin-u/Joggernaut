from datetime import date, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient, APITestCase

from api.models import UserProfiles

UserModel = get_user_model()


class UserViewsTestCase(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = UserModel.objects.create_user(
            email="user@email.com",
            firstname="First",
            lastname="Last",
            password="oldPass1@",
            phonenumber="09270001111",
        )  # type: ignore
        self.admin_user = UserModel.objects.create_superuser(
            email="test@gmail.com",
            firstname="First",
            lastname="Last",
            password="oldPass1@",
            phonenumber="09270001122",
        )  # type: ignore

        self.app, _ = Application.objects.get_or_create(
            name="Test App",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
        )
        self.token = AccessToken.objects.create(
            user=self.admin_user,
            scope="write read",
            expires=now() + timedelta(days=1),
            token="testtoken123",
            application=self.app,
        )

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.token}")

    def test_view_user_info(self):
        response = self.client.get("/api/user/info/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_update_user_info(self):
        response = self.client.patch("/api/user/info/update", {"email": "newemail@example.com"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_change_password(self):
        response = self.client.patch(
            "/api/user/password/change",
            {"new_password": "newPass@123", "confirm_password": "newPass@123"},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_view_user_profile(self):
        response = self.client.get("/api/profile/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    # Deprecated: User profile is automatically created with user account now
    # def test_create_user_profile(self):
    #     response = self.client.post(
    #         "/api/profile/new",
    #         {
    #             "userid": str(self.user.userid),
    #             "accountname": "TestAccount",
    #             "dateofbirth": "2025-02-25",
    #             "gender": "Male",
    #             "address": "Test Street",
    #             "height_cm": Decimal("160.00"),
    #             "weight_kg": Decimal("70.00"),
    #         },
    #     )
    #     self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_update_user_profile(self):
        profile = UserProfiles.objects.get(userid=self.admin_user)
        profile.accountname = "TestAccount"
        profile.dateofbirth = date(year=2025, month=2, day=25)
        profile.gender = "Male"
        profile.height_cm = Decimal("160.00")
        profile.weight_kg = Decimal("70.00")

        response = self.client.patch(
            "/api/profile/update",
            {
                "userid": str(self.admin_user.userid),
                "accountname": "UpdatedAccount",
                "dateofbirth": "2025-02-26",
                "gender": "Male",
                "height_cm": "160.00",
                "weight_kg": "70.00",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_delete_user(self):
        response = self.client.post("/api/user/delete", {"delete": True, "confirm_delete": True})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_ban_and_unban_user(self):
        self.assertTrue(self.user.is_active)

        response = self.client.post("/api/admin/ban/", {"userid": str(self.user.userid)})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertFalse(self.user.is_active)

        response = self.client.post("/api/admin/unban/", {"userid": str(self.user.userid)})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertTrue(self.user.is_active)
