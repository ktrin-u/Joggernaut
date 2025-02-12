from django.test import TestCase
from django.core.exceptions import ValidationError
from api.validators import validate_phoneNumber

class TestValidator(TestCase):

    def test_valid_phonenumber(self):
        valid_phone = "09171112222"
        try:
            validate_phoneNumber(valid_phone)
        except ValidationError:
            self.fail(f"{valid_phone} should be a valid phone number")

    def test_invalid_starting_digit(self):
        invalid_phone = "19171234567" # wrong starting digit
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

    def test_invalid_length(self):
        invalid_phone = "0917111222"  # < 11 digits
        with self.assertRaises(ValidationError): 
            validate_phoneNumber(invalid_phone)

        invalid_phone = "091711122223"  # > 11 digits
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)

    def test_invalid_prefix(self):
        invalid_phone = "09001112222"  # invalid prefix
        with self.assertRaises(ValidationError):
            validate_phoneNumber(invalid_phone)
