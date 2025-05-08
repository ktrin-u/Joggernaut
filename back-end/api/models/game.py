from django.db import models

from .user import User


class GameCharacterColor(models.TextChoices):
    RED = "RED"
    PURPLE = "PURPLE"
    YELLOW = "YELLOW"
    BLUE = "BLUE"


class GameCharacterClass(models.TextChoices):
    KNIGHT = "KNIGHT"
    ARCHER = "ARCHER"
    PAWN = "PAWN"


class GameSave(models.Model):
    id = models.AutoField(primary_key=True, editable=False)
    owner = models.OneToOneField(User, on_delete=models.CASCADE, db_column="owner_user")
    attempts_lifetime = models.PositiveIntegerField(default=0)

    def plus_attempt(self, count: int = 1):
        self.attempts_lifetime += count
        self.save()


class GameCharacter(models.Model):
    gamesave_id = models.ForeignKey(GameSave, on_delete=models.CASCADE, db_column="gamesave_id")
    id = models.AutoField(primary_key=True, editable=False, db_column="character_id")
    name = models.CharField(max_length=32, default="Unnamed")
    color = models.CharField(
        max_length=6, choices=GameCharacterColor, default=GameCharacterColor.RED
    )
    type = models.CharField(
        name="type",
        max_length=6,
        choices=GameCharacterClass,
        default=GameCharacterClass.PAWN,
        db_column="type",
    )
    health = models.PositiveIntegerField(default=1)
    speed = models.PositiveIntegerField(default=1)
    strength = models.PositiveIntegerField(default=1)
    stamina = models.PositiveIntegerField(default=1)
    selected = models.BooleanField(default=False)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["gamesave_id"],
                condition=models.Q(selected=True),
                name="unique-selected-per-gamesave",
            )
        ]

    def select(self) -> None:
        """
        Set field selected to True for the instance, while setting the values of field select to False for other instances.

        Returns None
        """
        try:
            selected_characters = GameCharacter.objects.filter(
                gamesave_id=self.gamesave_id, selected=True
            )

            for character in selected_characters:
                character.selected = False
                character.save()
            self.selected = True
            self.save()
        except Exception as e:
            raise e


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
