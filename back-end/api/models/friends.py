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

    class Meta:
        verbose_name = "Friend Activity"
        verbose_name_plural = "Friend Activities"
        constraints = [
            models.CheckConstraint(
                name="no self poke", check=~models.Q(toUserid=models.F("fromUserid"))
            )
        ]

    def clean(self) -> None:
        self.refresh_status()
        if self.fromUserid == self.toUserid:
            raise ValidationError({"toUserid": "not allowed to match with key fromUserid"})

    @property
    def deadline(self) -> timezone.datetime | None:
        if self.durationSecs == 0:
            return None
        offset = timezone.timedelta(seconds=self.durationSecs)
        if self.status == FriendActivityStatus.ONGOING and self.statusDate:
            return self.statusDate + offset
        return self.creationDate + offset

    @property
    def expired(self) -> bool:
        self.refresh_status()
        if self.durationSecs == 0 or self.deadline is None:  # 0 means cannot expire;
            return False

        return self.status == FriendActivityStatus.EXPIRED

    def update_status(self, new_status: FriendActivityStatus):
        if new_status not in FriendActivityStatus:
            raise ValueError(f"{new_status} is not in enum FriendActivityStatus.")
        self.status = new_status
        self.statusDate = timezone.now()
        self.save()

    def refresh_status(self):
        if self.deadline and timezone.now() > self.deadline:
            match self.status:
                case FriendActivityStatus.ONGOING:
                    self.update_status(FriendActivityStatus.FINISHED)
                case FriendActivityStatus.PENDING:
                    self.update_status(FriendActivityStatus.EXPIRED)
                case _:
                    pass
