from django.urls import path

from . import views

urlpatterns = [
    path("", views.Api_overview, name="overview")
]
