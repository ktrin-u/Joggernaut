from django.core.exceptions import ValidationError

SPECIALCHARS = "{}()[]#:;^,.?!|&_`~@$%/\\=+-*\"\'"


def validate_phoneNumber(value: str) -> None:
    prefix = value[:2]  # get the first two digits
    valid = True
    match prefix:
        case "63":
            if len(value) < 12:
                valid = False
        case "09":
            if len(value) < 11:
                valid = False
        case _:
            valid = False
    if not valid:
        raise ValidationError(f"Not a valid Philippine phone number: {value}")


def validate_rawpassword(value: str) -> None:
    if len(value) < 7:
        raise ValidationError("password must be at least 7 characters")

    hasCapital = False
    hasNumber = False
    hasSpecial = False

    for char in value:
        if hasCapital and hasNumber and hasSpecial:
            break
        if char.isupper():
            hasCapital = True
        if char.isnumeric():
            hasNumber = True
        if char in SPECIALCHARS:
            hasSpecial = True

    valid = hasCapital and hasNumber and hasSpecial

    if not valid:
        raise ValidationError("password must at least have one capital, one number, one special character")
