from django.db import models
from django.utils import timezone
from django.core.exceptions import ValidationError

from api.models.user import User


class FriendTable(models.Model):
    class FriendshipStatus(models.TextChoices):
        PENDING = "PEN"
        ACCEPTED = "ACC"

    friendid = models.BigAutoField(
        verbose_name="Friend ID", primary_key=True, unique=True
    )
    fromUserid = models.ForeignKey(
        User, models.CASCADE, db_column="fromUserID", related_name="friend_fromUserid"
    )
    toUserid = models.ForeignKey(
        User, models.CASCADE, db_column="toUserID", related_name="friend_toUserid"
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

        # if self.__class__.objects.filter(models.Q(fromUserid=self.fromUserid, toUserid=self.toUserid) | models.Q(fromUserid=self.toUserid, toUserid=self.fromUserid)):
        #     raise ValidationError(
        #         {
        #             "fromUserid": "friendship entry already exists",
        #             "toUserid": "friendship entry already exists",
        #         }
        #     )

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


class FriendActivity(models.Model):
    activityid = models.BigAutoField(
        verbose_name="activity id", primary_key=True, unique=True
    )
    fromUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="fromUserID",
        related_name="friendactivity_fromUserid",
    )
    toUserid = models.ForeignKey(
        User,
        models.CASCADE,
        db_column="toUserID",
        related_name="friendactivity_toUserid",
    )
    activity = models.CharField(max_length=3, choices=FriendActivityChoices)
    creationDate = models.DateTimeField(auto_now_add=True)
    accept = models.BooleanField(default=False)
    acceptDate = models.DateTimeField(null=True, blank=True)

    def clean(self):
        if self.fromUserid == self.toUserid:
            raise ValidationError(
                {"toUserid": "not allowed to match with key fromUserid"}
            )

    def accept_activity(self) -> None:
        self.accept = True
        self.acceptDate = timezone.now()
        self.save()

    class Meta:
        verbose_name = "Friend Activity"
        verbose_name_plural = "Friend Activities"
        constraints = [
            models.CheckConstraint(
                name="no self poke", check=~models.Q(toUserid=models.F("fromUserid"))
            )
        ]
