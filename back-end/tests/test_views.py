from django.test import TestCase
from rest_framework import status
from django.urls import reverse
from api.models import User

class TestView(TestCase):

    def setUp(self):
        self.test_user = User.objects.create(
            phonenumber="09157778888",
            email="taken@example.com"
        )

    # test case for api

    def test_api_overview(self):
        url = reverse("overview")
        response = self.client.get(url)

        self.assertEqual(response.json(), {"msg": "Welcome"})

    # test cases for email checking

    def test_check_taken_email(self):
        url = reverse("verify email number")
        response = self.client.get(url, {"email": "taken@example.com"})

        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(response.json(), {"msg": "taken"})

    def test_check_valid_email(self):
        url = reverse("verify email number")
        response = self.client.get(url, {"email": "new@example.com"})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {"msg": "valid"})

    # test cases for phone number checking

    def test_check_taken_phonenumber(self):
        url = reverse("verify phone number")
        response = self.client.get(url, {"phonenumber": "09157778888"})

        self.assertEqual(response.status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(response.json(), {"msg": "taken"})

    def test_check_valid_phonenumber(self):
        url = reverse("verify phone number")
        response = self.client.get(url, {"phonenumber": "09157776666"})

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json(), {"msg": "valid"})

