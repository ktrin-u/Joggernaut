from django.test import TestCase
from api.forms import UserChangeForm
from api.models import User

class TestUserChangeForm(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )

    def test_user_change_form(self):
        form = UserChangeForm(instance=self.user)

        self.assertEqual(form.initial["email"], self.user.email)
        self.assertEqual(form.initial["phonenumber"], self.user.phonenumber)

        self.assertIn("password", form.fields)
        self.assertEqual(form.fields["password"].help_text, '')

    def test_update_user_information(self):
        form_data = {
            "email": "newemail@email.com",
            "phonenumber": "09173334444",
            "firstname": "NewFirst",
            "lastname": "NewLast",
            "is_superuser": False,
        }

        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertTrue(form.is_valid(), form.errors)

        user = form.save()
        self.assertEqual(user.email, "newemail@email.com")
        self.assertEqual(user.phonenumber, "09173334444")
        self.assertEqual(user.firstname, "NewFirst")
        self.assertEqual(user.lastname, "NewLast")
        self.assertFalse(user.is_superuser)

    def test_invalid_email_format(self):
        form_data = {
            "email": "invalid-email",
            "phonenumber": self.user.phonenumber,
            "firstname": self.user.firstname,
            "lastname": self.user.lastname,
            "password": self.user.password,
        }

        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn("email", form.errors)