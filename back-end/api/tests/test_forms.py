from django.test import TestCase
from api.forms import UserChangeForm, SignupForm
from api.models import User


class TestUserChangeForm(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(  # type: ignore
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
        self.assertEqual(form.fields["password"].help_text, "")

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

    def test_form_with_extra_fields(self):
        form_data = {
            "email": "newemail@email.com",
            "phonenumber": "09173334444",
            "firstname": "NewFirst",
            "lastname": "NewLast",
            "extra_field": "This should be ignored",
        }
        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertTrue(form.is_valid(), form.errors)

    def test_invalid_phonenumber_format(self):
        form_data = {
            "email": self.user.email,
            "phonenumber": "invalid-phone",
            "firstname": self.user.firstname,
            "lastname": self.user.lastname,
        }
        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn("phonenumber", form.errors)

    def test_missing_required_fields(self):
        form_data = {
            "email": "",
            "phonenumber": "",
            "firstname": "",
            "lastname": "",
        }
        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertFalse(form.is_valid())
        self.assertIn("email", form.errors)
        self.assertIn("phonenumber", form.errors)
        self.assertIn("firstname", form.errors)
        self.assertIn("lastname", form.errors)

    def test_user_change_form_initialization(self):
        form = UserChangeForm(instance=self.user)
        self.assertEqual(form.initial["email"], self.user.email)
        self.assertEqual(form.initial["phonenumber"], self.user.phonenumber)
        self.assertEqual(form.initial["firstname"], self.user.firstname)
        self.assertEqual(form.initial["lastname"], self.user.lastname)

    def test_valid_form_submission(self):
        form_data = {
            "email": "newemail@email.com",
            "phonenumber": "09173334444",
            "firstname": "NewFirst",
            "lastname": "NewLast",
        }
        form = UserChangeForm(instance=self.user, data=form_data)
        self.assertTrue(form.is_valid(), form.errors)
        user = form.save()
        self.assertEqual(user.email, "newemail@email.com")
        self.assertEqual(user.phonenumber, "09173334444")
        self.assertEqual(user.firstname, "NewFirst")
        self.assertEqual(user.lastname, "NewLast")