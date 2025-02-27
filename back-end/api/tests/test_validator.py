from django.test import TestCase
from django.core.exceptions import ValidationError
from api.validators import validate_phoneNumber, CustomPasswordValidator


class TestValidator(TestCase):

    def setUp(self):
        self.password_validator = CustomPasswordValidator()

    def test_valid_phonenumber(self):
        valid_phone = "09171112222"
        try:
            validate_phoneNumber(valid_phone)
        except ValidationError:
            self.fail(f"{valid_phone} should be a valid phone number")

    def test_invalid_phonenumber_starting_digit(self):
        invalid_phone = "19171234567"  # wrong starting digit
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

    def test_invalid_phonenumber_length(self):
        invalid_phone = "0917111222"  # < 11 digits
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

        invalid_phone = "091711122223"  # > 11 digits
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

    def test_invalid_phonenumber_prefix(self):
        invalid_phone = "09001112222"  # invalid prefix
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

    def test_invalid_password_length(self) -> None:
        invalid_password = "Am1!"
        with self.assertRaises(ValidationError):
            self.password_validator.validate(invalid_password)

    def test_invalid_upper_character(self) -> None:
        invalid_password = "amazin1g!"
        with self.assertRaises(ValidationError):
            self.password_validator.validate(invalid_password)

    def test_invalid_digit_character(self) -> None:
        invalid_password = "Amazing!"
        with self.assertRaises(ValidationError):
            self.password_validator.validate(invalid_password)

    def test_invalid_special_characters(self) -> None:
        invalid_password = "Amazing1"
        with self.assertRaises(ValidationError):
            self.password_validator.validate(invalid_password)
