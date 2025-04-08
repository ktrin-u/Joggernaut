from datetime import timedelta
from uuid import uuid4

from django.test import TestCase
from django.urls import reverse
from django.utils.timezone import now
from oauth2_provider.models import AccessToken, Application
from rest_framework import status
from rest_framework.test import APIClient

from api.models import User, WorkoutRecord


class TestWorkoutRecordView(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Create a test user
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171234567",
            firstname="Test",
            lastname="User",
            password="TestPassword123",
        )

        # Create an OAuth2 application
        self.application = Application.objects.create(
            name="Test Application",
            client_type=Application.CLIENT_CONFIDENTIAL,
            authorization_grant_type=Application.GRANT_PASSWORD,
            user=self.user,
        )

        # Create an access token with the required scopes
        self.access_token = AccessToken.objects.create(
            user=self.user,
            scope="read write",
            expires=now() + timedelta(days=1),
            token="test-access-token",
            application=self.application,
        )

        # Authenticate the client with the access token
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.access_token.token}")

        # Create workout records
        self.workout1 = WorkoutRecord.objects.create(
            userid=self.user,
            calories=100,
            steps=1000,
        )
        self.workout2 = WorkoutRecord.objects.create(
            userid=self.user,
            calories=200,
            steps=2000,
        )

        # Define the URL for the workout records endpoint
        self.workout_url = reverse("workout records")

    def test_get_workout_records_no_filter(self):
        """Test retrieving all workout records without a filter."""
        response = self.client.get(self.workout_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_workout_records_with_filter(self):
        """Test retrieving workout records filtered by user ID."""
        response = self.client.get(self.workout_url, {"userid": str(self.user.userid)})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_workout_records_invalid_userid(self):
        """Test retrieving workout records with an invalid user ID."""
        response = self.client.get(self.workout_url, {"userid": str(uuid4())})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_workout_records_invalid_query_param(self):
        """Test retrieving workout records with an invalid query parameter."""
        response = self.client.get(self.workout_url, {"invalid_param": "value"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_post_workout_record_valid(self):
        """Test creating a new workout record with valid data."""
        data = {
            "calories": 150,
            "steps": 1500,
        }
        response = self.client.post(self.workout_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_post_workout_record_invalid(self):
        """Test creating a new workout record with invalid data."""
        data = {
            "calories": 0,
            "steps": 0,
        }
        response = self.client.post(self.workout_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_patch_workout_record_valid(self):
        """Test updating an existing workout record with valid data."""
        data = {
            "workoutid": self.workout1.workoutid,
            "calories": 300,
            "steps": 3000,
        }
        response = self.client.patch(self.workout_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_patch_workout_record_not_found(self):
        """Test updating a workout record that does not exist."""
        data = {
            "workoutid": 9999,
            "calories": 300,
            "steps": 3000,
        }
        response = self.client.patch(self.workout_url, data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
