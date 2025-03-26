from django.db import models

from .user import User


class GameSave(models.Model):
    id = models.AutoField(primary_key=True, editable=False)
    owner = models.OneToOneField(User, on_delete=models.CASCADE, db_column="owner_user")


class GameCharacter(models.Model):
    gamesave_id = models.ForeignKey(GameSave, on_delete=models.CASCADE, db_column="gamesave_id")
    id = models.AutoField(primary_key=True, editable=False, db_column="character_id")
    name = models.CharField(max_length=32)
    color_hex = models.CharField(max_length=7)
    health = models.PositiveIntegerField(default=1)
    speed = models.PositiveIntegerField(default=1)
    strength = models.PositiveIntegerField(default=1)
    stamina = models.PositiveIntegerField(default=1)


class GameEnemy(models.Model):
    id = models.AutoField(primary_key=True, editable=False, db_column="enemy_id")
    name = models.CharField(max_length=128)
    health = models.PositiveIntegerField(default=1)
    damage = models.PositiveIntegerField(default=1)
    speed = models.PositiveIntegerField(default=1)
    defense = models.PositiveIntegerField(default=1)

    class Meta:
        verbose_name_plural = "Game enemies"


class GameAchievement(models.Model):
    id = models.AutoField(primary_key=True, editable=False, db_column="achievement_id")
    name = models.CharField(max_length=128)
    description = models.TextField()


class GameAchievementLog(models.Model):
    gamesave_id = models.ForeignKey(GameSave, on_delete=models.CASCADE, db_column="gamesave_id")
    achievement_id = models.ForeignKey(
        GameAchievement, on_delete=models.CASCADE, db_column="achievement_id"
    )
    date = models.DateTimeField(auto_now_add=True)
