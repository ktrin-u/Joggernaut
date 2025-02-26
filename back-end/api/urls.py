from drf_spectacular.views import SpectacularSwaggerView, SpectacularAPIView
from django.urls import path
from . import views

urlpatterns = [
    path("register/", views.CreateUserView.as_view(), name="register new user"),
    path("user/profile/", views.UserProfileView.as_view(), name="retrieve user profile"),
    path("user/profile/new", views.CreateUserProfileView.as_view(), name="retrieve user profile"),
    path("user/profile/update", views.UpdateUserProfileView.as_view(), name="update user profile"),
    path("user/delete", views.DeleteUserView.as_view(), name="delete user account"),
    path("user/info/", views.ViewUserInfoView.as_view(), name="retrieve user info"),
    path("user/info/update", views.UpdateUserInfoView.as_view(), name="update user info"),
    path("user/password/change", views.UpdateUserPasswordView.as_view(), name="change user password"),
    path("admin/ban/", views.BanUserView.as_view(), name="ban a user"),
    path("admin/unban/", views.UnbanUserView.as_view(), name="unban a user"),
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('', SpectacularSwaggerView.as_view(url_name='schema'), name='overview'),
    path('login/', views.TokenAPIView.as_view(), name="login and acquire token"),
    path('logout/', views.RevokeTokenAPIView.as_view(), name="logout and revoke token"),
]
