from django import forms
from .validators import validate_phoneNumber, validate_rawpassword


class SignupForm(forms.Form):
    firstname = forms.CharField(max_length=50)
    lastname = forms.CharField(max_length=50)
    email = forms.EmailField(max_length=100)  # automatically runs EmailValidator
    phonenumber = forms.CharField(max_length=15, validators=validate_phoneNumber)  # type:ignore
    password = forms.CharField(max_length=255, validators=validate_rawpassword)  # type:ignore
