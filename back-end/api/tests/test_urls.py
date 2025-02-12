from django.test import SimpleTestCase
from django.urls import reverse, resolve
from api.views import check_taken_phonenumber, check_taken_email, Api_overview, CreateUserView


class TestUrls(SimpleTestCase):
    def test_api_overview_url(self):
        url = reverse('overview')
        self.assertEqual(resolve(url).func, Api_overview)

    def test_verify_phone_url(self):
        url = reverse('verify phone number')
        self.assertEqual(resolve(url).func, check_taken_phonenumber)

    def test_verify_email_url(self):
        url = reverse('verify email number')
        self.assertEqual(resolve(url).func, check_taken_email)

    def test_register_url(self):
        url = reverse('register new user')
        self.assertEqual(resolve(url).func.view_class, CreateUserView)
