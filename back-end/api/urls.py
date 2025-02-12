from django.urls import path
from . import views

urlpatterns = [
    path("", views.Api_overview, name="overview"),
    path("verify/phone/", views.check_taken_phonenumber, name="verify phone number"),
    path("verify/email/", views.check_taken_email, name="verify email number"),
    path("register/", views.CreateUserView.as_view(), name="register new user"),
]
