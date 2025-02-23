from drf_spectacular.views import SpectacularSwaggerView, SpectacularAPIView
from django.urls import path
from . import views

urlpatterns = [
    path("register/", views.CreateUserView.as_view(), name="register new user"),
    path("user/profile/", views.UserProfileView.as_view(), name="retrieve user profile"),
    path("user/info/", views.UserView.as_view(), name="retrieve user info"),
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('', SpectacularSwaggerView.as_view(url_name='schema'), name='overview')
]
