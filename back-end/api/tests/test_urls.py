from django.test import SimpleTestCase
from django.urls import reverse, resolve
from api.views import CreateUserView


class TestUrls(SimpleTestCase):
    def test_register_url(self):
        url = reverse('register new user')
        self.assertEqual(resolve(url).func.view_class, CreateUserView)
