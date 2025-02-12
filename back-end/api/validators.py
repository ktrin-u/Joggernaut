from django.core.exceptions import ValidationError


def validate_phoneNumber(value: str) -> None:
    # list of valid mobile prefixes from https://www.prefix.ph/prefixes/2023-complete-list-of-philippine-mobile-network-prefixes/
    VALIDPREFIX = [
        "0817", "0895", "0896", "0897", "0898", "0905", "0906", "0907", "0908", "0909", "0910", "0912", "0915", "0916", "0917", "0918", "0919", "0920", "0921", "0922", "0923", "0924", "0925", "0926", "0927", "0928", "0929", "0930", "0931", "0932", "0933", "0934", "0935", "0936", "0937", "0938", "0939", "0940", "0941", "0942", "0943", "0945", "0946", "0947", "0948", "0949", "0950", "0951", "0953", "0954", "0955", "0956", "0961", "0965", "0966", "0967", "0973", "0974", "0975", "0976", "0977", "0978", "0979", "0991", "0992", "0993", "0994", "0995", "0996", "0997", "0998", "0999"
    ]

    if value[0] != "0":
        raise ValidationError(f"Starting digit is expected to be 0, got:{value[0]}")

    if len(value) != 11:
        raise ValidationError(f"Expected length 11, got {len(value)}")

    if value[:4] not in VALIDPREFIX:
        raise ValidationError(f"Mobile prefix {value[:4]} is not a valid mobile prefix in the Philippines")


class CustomPasswordValidator:
    def validate(self, password: str, user=None) -> None:
        SPECIALCHARS = "{}()[]#:;^,.?!|&_`~@$%/\\=+-*\"\'"

        if not any(char.isupper() for char in password):
            raise ValidationError("password must have at least one capital letter")

        if not any(char.isdigit() for char in password):
            raise ValidationError("password must have at least one number")

        if not any(char in SPECIALCHARS for char in password):
            raise ValidationError(f"password must have at least one of the following {SPECIALCHARS}")

    def get_help_test(self):
        return "help text for custom password vlaidator"
