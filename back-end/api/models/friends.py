from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone

from .user import User


class FriendTable(models.Model):
    class FriendshipStatus(models.TextChoices):
        PENDING = "PEN"
        ACCEPTED = "ACC"

    friendid = models.BigAutoField(verbose_name="Friend ID", primary_key=True, unique=True)
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
            raise ValidationError({"toUserid": "not allowed to match with key fromUserid"})

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
    REJECT = "REJ"
    CANCEL = "CAN"
    EXPIRED = "EXP"
    PENDING = "PEN"
    ONGOING = "ONG"
    FINISHED = "FIN"


class FriendActivity(models.Model):
    activityid = models.BigAutoField(verbose_name="activity id", primary_key=True, unique=True)
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
    details = models.CharField(max_length=255, blank=True, null=True)

    @property
    def deadline(self) -> timezone.datetime:
        offset = timezone.timedelta(seconds=self.durationSecs)
        if self.status == FriendActivityStatus.ONGOING:
            return self.statusDate + offset
        return self.creationDate + offset

    @property
    def expired(self) -> bool:
        try:
            match self.activity:
                case FriendActivityChoices.CHALLENGE:
                    time_elapsed = self.deadline - self.creationDate
                case _:
                    time_elapsed = timezone.now() - self.creationDate

            activity_duration = timezone.timedelta(seconds=self.durationSecs)

            if self.durationSecs == 0:  # 0 means cannot expire;
                return False

            if time_elapsed > activity_duration:
                match self.status:
                    case FriendActivityStatus.ONGOING:
                        self.status = FriendActivityStatus.FINISHED
                    case FriendActivityStatus.PENDING:
                        self.status = FriendActivityStatus.EXPIRED
                    case _:
                        pass
                self.statusDate = timezone.now()
                self.save()
                return True

            return False
        except Exception:
            return False

    def clean(self) -> None:
        _ = self.expired
        if self.fromUserid == self.toUserid:
            raise ValidationError({"toUserid": "not allowed to match with key fromUserid"})

    class Meta:
        verbose_name = "Friend Activity"
        verbose_name_plural = "Friend Activities"
        constraints = [
            models.CheckConstraint(
                name="no self poke", check=~models.Q(toUserid=models.F("fromUserid"))
            )
        ]

    def refresh_status(self):
        _ = self.expired
