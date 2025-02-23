from django.urls import path
from . import views

urlpatterns = [
    path("", views.Api_overview, name="overview"),
    path("register/", views.CreateUserView.as_view(), name="register new user"),
    path("user/profile/", views.UserProfileView.as_view(), name="retrieve user profile"),
]
