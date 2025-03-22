from django.test import TestCase
from django.db.utils import IntegrityError
from django.core.exceptions import ValidationError
from api.models import User, WorkoutRecord


class TestWorkoutRecord(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@email.com",
            phonenumber="09171112222",
            firstname="John",
            lastname="Doe",
            password="testPass1@",
        )

    def test_valid_workout_record_creation(self):
        record = WorkoutRecord.objects.create(
            userid=self.user,
            calories=100,
            steps=5000,
        )
        self.assertEqual(record.userid, self.user)
        self.assertEqual(record.calories, 100)
        self.assertEqual(record.steps, 5000)
        self.assertIsNotNone(record.creationDate)
        self.assertIsNotNone(record.lastUpdate)

    def test_non_zero_calories_or_steps_constraint(self):
        with self.assertRaises(IntegrityError):  # Expect IntegrityError for invalid data
            WorkoutRecord.objects.create(
                userid=self.user,
                calories=0,
                steps=0,
            )

    def test_negative_calories_or_steps(self):
        with self.assertRaises(ValidationError):
            record = WorkoutRecord(
                userid=self.user,
                calories=-100,  # Invalid negative value
                steps=5000,
            )
            record.full_clean()  # Trigger validation

        with self.assertRaises(ValidationError):
            record = WorkoutRecord(
                userid=self.user,
                calories=100,
                steps=-5000,  # Invalid negative value
            )
            record.full_clean()  # Trigger validation

    def test_automatic_timestamps(self):
        record = WorkoutRecord.objects.create(
            userid=self.user,
            calories=200,
            steps=1000,
        )
        self.assertIsNotNone(record.creationDate)
        self.assertIsNotNone(record.lastUpdate)