from datetime import date
from decimal import Decimal

from django.core.exceptions import ValidationError
from django.test import TestCase

from api.models import Gender, User, UserProfiles


class TestUserProfiles(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(  # type: ignore
            email="profile@email.com",
            phonenumber="09181112222",
            firstname="First",
            lastname="Last",
            password="testPass1@",
        )
        self.profile = UserProfiles.objects.get(userid=self.user)
        self.profile.accountname = "First Last"
        self.profile.dateofbirth = date(2025, 2, 13)
        self.profile.gender = Gender.MALE
        self.profile.height_cm = Decimal(180.5)
        self.profile.weight_kg = Decimal(75.0)

    def test_profile_creation(self):
        self.assertEqual(self.profile.accountname, "First Last")
        self.assertEqual(self.profile.gender, Gender.MALE)

    def test_profile_belongs_to_user(self):
        self.assertEqual(self.profile.userid, self.user)

    def test_unique_account_name(self):
        with self.assertRaises(ValidationError):
            duplicate_profile = UserProfiles(
                userid=self.user,
                accountname="First Last",  # Duplicate account name
                dateofbirth=date(2000, 1, 1),
                gender=Gender.FEMALE,
                height_cm=160.0,
                weight_kg=50.0,
            )
            duplicate_profile.full_clean()  # Trigger validation

    def test_invalid_gender(self):
        with self.assertRaises(ValidationError):
            invalid_profile = UserProfiles(
                userid=self.user,
                accountname="Invalid Gender",
                dateofbirth=date(2000, 1, 1),
                gender="INVALID",  # Invalid gender
                height_cm=160.0,
                weight_kg=50.0,
            )
            invalid_profile.full_clean()  # Trigger validation

    def test_invalid_height_or_weight(self):
        with self.assertRaises(ValidationError):
            invalid_profile = UserProfiles(
                userid=self.user,
                accountname="Invalid Height",
                dateofbirth=date(2000, 1, 1),
                gender=Gender.MALE,
                height_cm=-180.0,  # Invalid negative height
                weight_kg=75.0,
            )
            invalid_profile.full_clean()  # Trigger validation

        with self.assertRaises(ValidationError):
            invalid_profile = UserProfiles(
                userid=self.user,
                accountname="Invalid Weight",
                dateofbirth=date(2000, 1, 1),
                gender=Gender.MALE,
                height_cm=180.0,
                weight_kg=-75.0,  # Invalid negative weight
            )
            invalid_profile.full_clean()  # Trigger validation

    def test_date_of_birth_in_future(self):
        with self.assertRaises(ValidationError):
            future_profile = UserProfiles(
                userid=self.user,
                accountname="Future DOB",
                dateofbirth=date(2030, 1, 1),  # Future date
                gender=Gender.MALE,
                height_cm=180.0,
                weight_kg=75.0,
            )
            future_profile.full_clean()  # Trigger validation
