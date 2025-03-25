from django.test import TestCase
from api.forms import SignupForm


class TestSignupForm(TestCase):
    def test_valid_form_submission(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "John",
            "lastname": "Doe",
            "password1": "TestPassword123!",
            "password2": "TestPassword123!",
        }
        form = SignupForm(data=form_data)
        self.assertTrue(form.is_valid())  # Form should be valid
        user = form.save()
        self.assertEqual(user.firstname, "John")
        self.assertEqual(user.lastname, "Doe")
        self.assertTrue(user.check_password("TestPassword123!"))  # Password should be hashed

    def test_password_mismatch(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "John",
            "lastname": "Doe",
            "password1": "TestPassword123!",
            "password2": "DifferentPassword123!",
        }
        form = SignupForm(data=form_data)
        self.assertFalse(form.is_valid())  # Form should be invalid
        self.assertIn("password2", form.errors)  # Password mismatch error
        self.assertEqual(form.errors["password2"][0], "Passwords don't match")

    def test_missing_required_fields(self):
        form_data = {
            "phonenumber": "",
            "firstname": "",
            "lastname": "",
            "password1": "TestPassword123!",
            "password2": "TestPassword123!",
        }
        form = SignupForm(data=form_data)
        self.assertFalse(form.is_valid())  # Form should be invalid
        self.assertIn("phonenumber", form.errors)
        self.assertIn("firstname", form.errors)
        self.assertIn("lastname", form.errors)

    def test_password_hashing(self):
        form_data = {
            "phonenumber": "09171112222",
            "firstname": "John",
            "lastname": "Doe",
            "password1": "TestPassword123!",
            "password2": "TestPassword123!",
        }
        form = SignupForm(data=form_data)
        self.assertTrue(form.is_valid())  # Form should be valid
        user = form.save()
        self.assertNotEqual(user.password, "TestPassword123!")  # Password should not be stored in plain text
        self.assertTrue(user.check_password("TestPassword123!"))  # Password should be hashed
