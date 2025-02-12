from .models import User
from django.contrib import admin
from .forms import UserChangeForm, SignupForm
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin


class UserAdmin(BaseUserAdmin):
    form = UserChangeForm
    add_form = SignupForm


admin.site.register(User)
