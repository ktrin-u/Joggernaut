from django.db import models

from .friends import FriendActivity
from .user import User


class WorkoutRecord(models.Model):
    workoutid = models.BigAutoField(primary_key=True, unique=True)  # Field name made lowercase.
    userid = models.ForeignKey(
        User, models.CASCADE, db_column="userID"
    )  # Field name made lowercase.
    calories = models.PositiveIntegerField(default=0)
    steps = models.PositiveIntegerField(default=0)
    creationDate = models.DateTimeField(auto_now_add=True)
    lastUpdate = models.DateTimeField(auto_now=True)
    activityid = models.ForeignKey(
        FriendActivity,
        models.CASCADE,
        db_column="activityid",
        to_field="activityid",
        null=True,
        blank=True,
        default=None,
    )

    class Meta:
        db_table = "workout_record"
        verbose_name = "Workout Record"
        verbose_name_plural = "Workout Records"
        # constraints = [
        #     models.CheckConstraint(
        #         name="non-zero calories or steps",
        #         check=~models.Q(models.Q(calories=0) & models.Q(steps=0)),
        #     )
        # ]
