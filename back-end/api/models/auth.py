from django.db import models
from django.utils import timezone
from django_backend.settings import PASSWORD_RESET_TIMEOUT

from api.models import User

from datetime import timedelta


class PasswordResetToken(models.Model):
    user_email = models.ForeignKey(
        User, on_delete=models.CASCADE, to_field="email", db_column="user_email"
    )
    token = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def expired(self):
        try:
            time_elapsed = timezone.now() - self.created_at
            activity_duration = timedelta(seconds=PASSWORD_RESET_TIMEOUT)

            if PASSWORD_RESET_TIMEOUT == 0:  # 0 means cannot expire
                return False

            if time_elapsed > activity_duration:
                return True
            return False
        except Exception:
            return True  # safer to assume it is expired when it cannot be verified
