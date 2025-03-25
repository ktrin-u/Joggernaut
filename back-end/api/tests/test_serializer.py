import datetime
from decimal import Decimal
from unittest.mock import MagicMock, patch

from django.contrib.auth import get_user_model
from django.test import TestCase

from api.serializers.user import (
    RegisterFormSerializer,
    UpdateUserPasswordSerializer,
    UserDeleteSerializer,
)
from api.serializers.user_profile import UserProfileFormSerializer

UserModel = get_user_model()


class TestRegisterFormSerializer(TestCase):
    def setUp(self):
        self.valid_data = {
            "firstname": "First",
            "lastname": "Last",
            "email": "test@email.com",
            "phonenumber": "09171112222",
            "password": "testPass1@",
        }

    def test_valid_serializer(self):
        serializer = RegisterFormSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())

    def test_invalid_email(self):
        invalid_data = self.valid_data.copy()
        invalid_data["email"] = "invalid_email"
        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("email", serializer.errors)

    def test_invalid_phone_number(self):
        invalid_data = self.valid_data.copy()
        invalid_data["phonenumber"] = "invalid_phone"
        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("phonenumber", serializer.errors)

    def test_missing_field(self):
        invalid_data = self.valid_data.copy()
        del invalid_data["email"]
        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("email", serializer.errors)

    @patch("api.models.UserManager.create_user")
    def test_create_user_calls_user_manager(self, mock_create_user):
        mock_user = MagicMock()
        mock_create_user.return_value = mock_user

        serializer = RegisterFormSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())

        serializer.save()

        mock_create_user.assert_called_once_with(
            email=self.valid_data["email"],
            firstname=self.valid_data["firstname"],
            lastname=self.valid_data["lastname"],
            password=self.valid_data["password"],
            phonenumber=self.valid_data["phonenumber"],
        )

        mock_user.set_password.assert_called_once_with(self.valid_data["password"])
        mock_user.save.assert_called_once()


class TestUpdateUserPasswordSerializer(TestCase):
    def setUp(self):
        self.user = UserModel.objects.create_user(
            email="test@email.com",
            firstname="first",
            lastname="last",
            password="oldPass1@",
            phonenumber="09270001111",
        )  # type: ignore
        self.valid_data = {"new_password": "NewPass1@", "confirm_password": "NewPass1@"}

    def test_valid_serializer(self):
        serializer = UpdateUserPasswordSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())

    def test_password_mismatch(self):
        invalid_data = self.valid_data.copy()
        invalid_data["confirm_password"] = "Mismatch1@"
        serializer = UpdateUserPasswordSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("new_password", serializer.errors)
        self.assertIn("confirm_password", serializer.errors)
        self.assertEqual(serializer.errors["new_password"][0], "match failed")
        self.assertEqual(serializer.errors["confirm_password"][0], "match failed")

    def test_invalid_password_format(self):
        invalid_data = self.valid_data.copy()
        invalid_data["new_password"] = "short"
        invalid_data["confirm_password"] = "short"
        serializer = UpdateUserPasswordSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("new_password", serializer.errors)

    def test_update_user_password(self):
        serializer = UpdateUserPasswordSerializer(
            instance=self.user, data=self.valid_data
        )
        self.assertTrue(serializer.is_valid())

        updated_user = serializer.update(self.user, serializer.validated_data)
        self.assertTrue(updated_user.check_password(self.valid_data["new_password"]))


class TestUserProfileFormSerializer(TestCase):
    def setUp(self):
        self.user = UserModel.objects.create_user(
            email="test@email.com",
            firstname="First",
            lastname="Last",
            password="oldPass1@",
            phonenumber="09270001111",
        )  # type: ignore
        self.valid_data = {
            "userid": self.user.userid,
            "accountname": "TestAccount",
            "dateofbirth": datetime.date(2025, 2, 25),
            "gender": "Male",
            "address": "Test Street",
            "height_cm": Decimal("160.00"),
            "weight_kg": Decimal("70.00"),
        }

    def test_create_user_profile(self):
        serializer = UserProfileFormSerializer(data=self.valid_data)
        self.assertTrue(serializer.is_valid())

    def test_invalid_height(self):
        invalid_data = self.valid_data.copy()
        invalid_data["height_cm"] = Decimal("160000.00")  # Invalid height with 6 digits
        serializer = UserProfileFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("height_cm", serializer.errors)

    def test_invalid_weight(self):
        invalid_data = self.valid_data.copy()
        invalid_data["weight_kg"] = Decimal("70000.00")  # Invalid weight with 6 digits
        serializer = UserProfileFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("weight_kg", serializer.errors)

    def test_missing_field(self):
        invalid_data = self.valid_data.copy()
        del invalid_data["accountname"]
        serializer = UserProfileFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("accountname", serializer.errors)


class TestUserDeleteSerializer(TestCase):
    def test_valid_delete(self):
        valid_data = {"delete": True, "confirm_delete": True}
        serializer = UserDeleteSerializer(data=valid_data)
        self.assertTrue(serializer.is_valid())

    def test_missing_delete_consent(self):
        invalid_data = {"delete": False, "confirm_delete": True}
        serializer = UserDeleteSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("delete", serializer.errors)

    def test_conflicting_delete_confirmation(self):
        invalid_data = {"delete": True, "confirm_delete": False}
        serializer = UserDeleteSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("confirm_delete", serializer.errors)
