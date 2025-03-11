from django.test import TestCase
from api.forms import SignupForm, UserChangeForm
from api.models import User


class TestSignupForm(TestCase):
    def test_valid_signup_form(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "First",
            "lastname": "Last",
            "password1": "testPass1@",
            "password2": "testPass1@",
        }

        form = SignupForm(data=form_data)
        self.assertTrue(form.is_valid(), form.errors)

    def test_password_mismatch(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "First",
            "lastname": "Last",
            "password1": "testPass1@",
            "password2": "wrongPass1@",
        }

        form = SignupForm(data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn("password2", form.errors)
        self.assertEqual(form.errors["password2"], ["Passwords don't match"])

    def test_save_user_correctly(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "First",
            "lastname": "Last",
            "password1": "testPass1@",
            "password2": "testPass1@",
        }

        form = SignupForm(data=form_data)
        self.assertTrue(form.is_valid())

        user = form.save()
        self.assertIsInstance(user, User)
        self.assertTrue(user.check_password("testPass1@"))
        self.assertEqual(user.firstname, "First")

    def test_save_user_incorrectly(self):
        form_data = {
            "phonenumber": "",
            "firstname": "",
            "lastname": "",
            "password1": "testPass1@",
            "password2": "testPass1@",
        }

        form = SignupForm(data=form_data)
        self.assertTrue(not form.is_valid())


class TestUserChangeForm(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )  # type: ignore

    def test_user_change_form(self):
        form = UserChangeForm(instance=self.user)

        self.assertEqual(form.initial["email"], self.user.email)
        self.assertEqual(form.initial["phonenumber"], self.user.phonenumber)

        self.assertIn("password", form.fields)
        self.assertEqual(form.fields["password"].help_text, "")
