from datetime import timedelta

from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone

from .user import User


class FriendTable(models.Model):
    class FriendshipStatus(models.TextChoices):
        PENDING = "PEN"
        ACCEPTED = "ACC"

    friendid = models.BigAutoField(
        verbose_name="Friend ID", primary_key=True, unique=True
    )
    fromUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="fromUserID",
        related_name="friend_fromUserid",
        to_field="userid",
    )
    toUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="toUserID",
        related_name="friend_toUserid",
        to_field="userid",
    )
    status = models.CharField(
        max_length=3, choices=FriendshipStatus.choices, default=FriendshipStatus.PENDING
    )
    creationDate = models.DateTimeField(auto_now_add=True)
    lastUpdate = models.DateTimeField(auto_now=True)

    def clean(self):
        if self.fromUserid == self.toUserid:
            raise ValidationError(
                {"toUserid": "not allowed to match with key fromUserid"}
            )

    class Meta:  # type: ignore
        constraints = [
            models.UniqueConstraint(
                name="two-way friendship",
                fields=["fromUserid", "toUserid"],
            ),
            models.UniqueConstraint(
                name="two-way friendship reverse", fields=["toUserid", "fromUserid"]
            ),
        ]


class FriendActivityChoices(models.TextChoices):
    POKE = "POK"
    CHALLENGE = "CHA"


class FriendActivityStatus(models.TextChoices):
    ACCEPT = "ACC"
    REJECT = "REJ"
    CANCEL = "CAN"
    EXPIRED = "EXP"
    PENDING = "PEN"


class FriendActivity(models.Model):
    activityid = models.BigAutoField(
        verbose_name="activity id", primary_key=True, unique=True
    )
    fromUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="fromUserID",
        related_name="friendactivity_fromUserid",
        to_field="userid",
    )
    toUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="toUserID",
        related_name="friendactivity_toUserid",
        to_field="userid",
    )
    activity = models.CharField(max_length=3, choices=FriendActivityChoices)
    creationDate = models.DateTimeField(auto_now_add=True)
    status = models.CharField(
        max_length=3, choices=FriendActivityStatus, default=FriendActivityStatus.PENDING
    )
    statusDate = models.DateTimeField(null=True, blank=True)
    durationSecs = models.PositiveIntegerField(default=3600)

    @property
    def expired(self) -> bool:
        try:
            time_elapsed = timezone.now() - self.creationDate
            activity_duration = timedelta(seconds=self.durationSecs)

            if self.durationSecs == 0:  # 0 means cannot expire
                return False

            if time_elapsed > activity_duration:
                if self.status != FriendActivityStatus.EXPIRED:
                    self.status = FriendActivityStatus.EXPIRED
                    self.statusDate = self.creationDate + activity_duration
                    self.save()
                return True
            return False
        except Exception:
            return False

    def clean(self) -> None:
        _ = self.expired
        if self.fromUserid == self.toUserid:
            raise ValidationError(
                {"toUserid": "not allowed to match with key fromUserid"}
            )

    def accept_activity(self) -> bool:
        """
        Returns True if success, False if fail since activity is already expired
        """
        if not self.expired:
            self.status = FriendActivityStatus.ACCEPT
            self.statusDate = timezone.now()
            self.save()
            return True
        return False

    def reject_activity(self) -> bool:
        if not self.expired:
            self.status = FriendActivityStatus.REJECT
            self.statusDate = timezone.now()
            self.save()
            return True
        return False

    def cancel_activity(self) -> bool:
        if not self.expired:
            self.status = FriendActivityStatus.CANCEL
            self.statusDate = timezone.now()
            self.save()
            return True
        return False

    class Meta:
        verbose_name = "Friend Activity"
        verbose_name_plural = "Friend Activities"
        constraints = [
            models.CheckConstraint(
                name="no self poke", check=~models.Q(toUserid=models.F("fromUserid"))
            )
        ]
