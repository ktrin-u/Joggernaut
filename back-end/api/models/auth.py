from django.db import models
from api.models import User


class PasswordResetToken(models.Model):
    user_email = models.ForeignKey(
        User, on_delete=models.CASCADE, to_field="email", db_column="user_email"
    )
    token = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
