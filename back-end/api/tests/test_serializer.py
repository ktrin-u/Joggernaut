from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from api.serializers import RegisterFormSerializer
from unittest.mock import MagicMock, patch

UserModel = get_user_model()

class TestSerializer(APITestCase):

    def test_valid_serializer(self):
        valid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'email': 'test@email.com',
            'phonenumber': '09171112222',
            'password': 'testPass1@',
        }

        serializer = RegisterFormSerializer(data=valid_data)
        self.assertTrue(serializer.is_valid())

        user = serializer.save()
        self.assertEqual(user.firstname, valid_data['firstname'])
        self.assertEqual(user.lastname, valid_data['lastname'])
        self.assertEqual(user.email, valid_data['email'])
        self.assertEqual(user.phonenumber, valid_data['phonenumber'])
        self.assertTrue(user.check_password(valid_data['password']))

    def test_invalid_email(self):
        invalid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'email': 'invalid',
            'phonenumber': '09171112222',
            'password': 'testPass1@',
        }

        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('email', serializer.errors)

    def test_invalid_password(self):
        invalid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'email': 'test@email.com',
            'phonenumber': '09171112222',
            'password': 'testpass1@',
        }

        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('password', serializer.errors)

    def test_missing_field(self):
        invalid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'phonenumber': '09171112222',
            'password': 'testPass1@',
        }

        serializer = RegisterFormSerializer(data=invalid_data)
        self.assertFalse(serializer.is_valid())
        self.assertIn('email', serializer.errors)

    def test_create_user(self):
        valid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'email': 'test@email.com',
            'phonenumber': '09171112222',
            'password': 'testPass1@',
        }

        serializer = RegisterFormSerializer(data=valid_data)
        self.assertTrue(serializer.is_valid())

        user = serializer.create(valid_data)
        self.assertIsInstance(user, UserModel)
        self.assertEqual(user.email, valid_data['email'])
        self.assertTrue(user.check_password(valid_data['password']))

    @patch("api.models.UserManager.create_user")
    def test_create_user_calls_user_manager(self, mock_create_user):
        mock_user = MagicMock()
        mock_create_user.return_value = mock_user

        valid_data = {
            'firstname': 'First',
            'lastname': 'Last',
            'email': 'test@email.com',
            'phonenumber': '09171112222',
            'password': 'testPass1@',
        }

        serializer = RegisterFormSerializer(data=valid_data)
        self.assertTrue(serializer.is_valid())

        serializer.save()

        mock_create_user.assert_called_once_with(
            email=valid_data["email"],
            firstname=valid_data["firstname"],
            lastname=valid_data["lastname"],
            password=valid_data["password"],
            phonenumber=valid_data["phonenumber"],
        )

        mock_user.set_password.assert_called_once_with(valid_data["password"])
        mock_user.save.assert_called_once()