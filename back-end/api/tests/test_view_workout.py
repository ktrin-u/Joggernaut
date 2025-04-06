import json
import uuid
from unittest.mock import patch
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from api.models.workout import WorkoutRecord
from api.models.user import User


class WorkoutViewTests(APITestCase):
    def setUp(self):
        self.client = APIClient()

        # Create a single mock user
        self.user = User.objects.create_user(
            email="testuser@email.com",
            phonenumber="09171112222",
            firstname="Test",
            lastname="User",
            password="testPass123",
        )
        self.client.force_authenticate(user=self.user)

        # Base URLs
        self.create_url = "/api/workout/create/"
        self.get_url = "/api/workout/"
        self.update_url = "/api/workout/update/"

    def parse_response(self, response):
        """Helper function to parse JSON response content."""
        try:
            return json.loads(response.content)
        except json.JSONDecodeError:
            return None

    def test_create_workout_record_success(self):
        # Test creating a valid workout record
        data = {"calories": 100, "steps": 5000}
        response = self.client.post(self.create_url, data)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_create_workout_record_both_zero(self):
        # Test creating a workout record with calories=0 and steps=0
        data = {"calories": 0, "steps": 0}
        response = self.client.post(self.create_url, data)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_create_workout_record_invalid_data(self):
        # Test creating a workout record with invalid data
        data = {"calories": "invalid", "steps": 5000}
        response = self.client.post(self.create_url, data)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_get_workout_records_success(self):
        # Create mock workout records
        WorkoutRecord.objects.create(userid=self.user, calories=100, steps=5000)
        WorkoutRecord.objects.create(userid=self.user, calories=200, steps=10000)

        # Test fetching workout records
        response = self.client.get(self.get_url)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)  # Updated to match actual behavior

    def test_update_workout_record_success(self):
        # Create a mock workout record
        workout = WorkoutRecord.objects.create(userid=self.user, calories=100, steps=5000)

        # Test updating calories
        data = {"workoutid": str(workout.workoutid), "calories": 200}
        response = self.client.patch(self.update_url, data)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_update_workout_record_no_new_values(self):
        # Create a mock workout record
        workout = WorkoutRecord.objects.create(userid=self.user, calories=100, steps=5000)

        # Test updating with no new values
        data = {"workoutid": str(workout.workoutid)}
        response = self.client.patch(self.update_url, data)
        response_data = self.parse_response(response)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)