# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.core.exceptions import ValidationError
from .validators import validate_phoneNumber
import uuid


class Status(models.TextChoices):
    ONLINE = 'online'
    IDLE = 'idle'
    DND = 'do not disturb'


class Gender(models.TextChoices):
    MALE = 'Male'
    FEMALE = 'Female'
    OTHER = 'Other'


class UserManager(BaseUserManager):
    def create_user(self, email, phonenumber, firstname, lastname, password=None):
        if not email:
            raise ValueError("users must have an email address")

        if not phonenumber:
            raise ValueError("users must have a phone number")

        if not firstname and not lastname:
            raise ValueError("users must have full name")

        user = self.model(
            email=self.normalize_email(email),
            phonenumber=phonenumber,
            firstname=firstname,
            lastname=lastname
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, phonenumber, firstname, lastname, password=None):
        user = self.create_user(email, phonenumber, firstname, lastname, password)
        user.is_superuser = True
        user.is_staff = True
        user.save(using=self._db)
        return user


class User(AbstractUser):
    userid = models.UUIDField(db_column='userID', primary_key=True, unique=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, max_length=100)
    phonenumber = models.CharField(db_column='phoneNumber', max_length=15, validators=[validate_phoneNumber], unique=True)  # Field name made lowercase.
    firstname = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    joindate = models.DateTimeField(db_column='joinDate', auto_now_add=True)  # Field name made lowercase.
    first_name = None
    last_name = None
    username = None
    date_joined = None

    objects = UserManager()  # type: ignore

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["phonenumber", "firstname", "lastname"]

    class Meta:
        db_table = 'users'
        ordering = ["userid"]
        verbose_name = "user"

    def ban(self):
        self.is_active = False

    def unban(self):
        self.is_active = True


class WorkoutRecord(models.Model):
    workoutid = models.BigAutoField(primary_key=True, unique=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    calories = models.PositiveIntegerField(default=0)
    steps = models.PositiveIntegerField(default=0)
    creationDate = models.DateTimeField(auto_now_add=True)
    lastUpdate = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'workout_record'
        verbose_name = "Workout Record"
        verbose_name_plural = "Workout Records"
        constraints = [
            models.CheckConstraint(
                name="non-zero calories or steps",
                check=~models.Q(models.Q(calories=0) & models.Q(steps=0)),
            )
        ]


class UserAuditLog(models.Model):
    logid = models.AutoField(db_column='logID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    action = models.CharField(max_length=50)
    details = models.TextField()
    timestamp = models.DateTimeField()

    class Meta:
        db_table = 'user_audit_log'
        verbose_name = "user audit log"
        verbose_name_plural = "user audit logs"


class UserProfiles(models.Model):
    # profileid = models.AutoField(db_column='profileID', primary_key=True)  # Field name made lowercase.
    # userid = models.ForeignKey(User, models.CASCADE, db_column='userID', unique=True)  # Field name made lowercase.
    userid = models.OneToOneField(User, on_delete=models.CASCADE, db_column='userID', primary_key=True)
    accountname = models.CharField(unique=True, max_length=50)
    dateofbirth = models.DateField(db_column='dateOfBirth')  # Field name made lowercase.
    gender = models.CharField(choices=Gender, max_length=6)
    address = models.TextField()
    height_cm = models.DecimalField(max_digits=5, decimal_places=2)
    weight_kg = models.DecimalField(max_digits=5, decimal_places=2)

    class Meta:
        db_table = 'user_profiles'
        verbose_name = "user profile"
        verbose_name_plural = "user profiles"


class UserSettings(models.Model):
    # settingid = models.AutoField(db_column='settingID', primary_key=True)  # Field name made lowercase.
    userid = models.OneToOneField(User, models.CASCADE, db_column='userID', primary_key=True)  # Field name made lowercase.
    status = models.CharField(choices=Status, max_length=14)

    class Meta:
        db_table = 'user_settings'
        verbose_name = "user settings"
        verbose_name_plural = "user settings"


class FriendTable(models.Model):

    class FriendshipStatus(models.TextChoices):
        PENDING = "PEN"
        ACCEPTED = "ACC"
        REJECTED = "REJ"

    friendid = models.BigAutoField(verbose_name="Friend ID", primary_key=True, unique=True)
    fromUserid = models.ForeignKey(User, models.CASCADE, db_column="fromUserID", related_name="friend_fromUserid")
    toUserid = models.ForeignKey(User, models.CASCADE, db_column="toUserID", related_name="friend_toUserid")
    status = models.CharField(max_length=3, choices=FriendshipStatus.choices, default=FriendshipStatus.PENDING)
    creationDate = models.DateTimeField(auto_now_add=True)
    lastUpdate = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                name="two-way friendship",
                fields=["fromUserid", "toUserid"],
            ),
            models.UniqueConstraint(
                name="two-way friendship reverse",
                fields=["toUserid", "fromUserid"]
            )
        ]
    def clean(self):
        if self.fromUserid == self.toUserid:
            raise ValidationError({"toUserid": "A user cannot send a friend request to themselves."})
        
        # Check for duplicate friendships (both directions), excluding the current instance
        if FriendTable.objects.filter(
            models.Q(fromUserid=self.fromUserid, toUserid=self.toUserid) |
            models.Q(fromUserid=self.toUserid, toUserid=self.fromUserid)
        ).exclude(friendid=self.friendid).exists():
            raise ValidationError({"__all__": "Duplicate friendship is not allowed."})
    def save(self, *args, **kwargs):
        self.full_clean()  # Ensure validation is triggered
        super().save(*args, **kwargs)
        
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
                name="two-way friendship reverse",
                fields=["toUserid", "fromUserid"]
            )
        ]


class FriendActivityChoices(models.TextChoices):
    POKE = "POK"
    CHALLENGE = "CHA"


class FriendActivity(models.Model):
    activityid = models.BigAutoField(verbose_name="activity id", primary_key=True, unique=True)
    fromUserid = models.ForeignKey(User, models.CASCADE, db_column="fromUserID", related_name="friendactivity_fromUserid")
    toUserid = models.ForeignKey(User, models.CASCADE, db_column="toUserID", related_name="friendactivity_toUserid")
    activity = models.CharField(max_length=3, choices=FriendActivityChoices)
    creationDate = models.DateTimeField(auto_now_add=True)
    accept = models.BooleanField(default=False)
    acceptDate = models.DateTimeField(null=True, blank=True)

    def clean(self):
        if self.fromUserid == self.toUserid:
            raise ValidationError({"toUserid": "not allowed to match with key fromUserid"})

    def accept_activity(self) -> None:
        self.accept = True
        self.acceptDate = timezone.now()
        self.save()

    class Meta:
        verbose_name = "Friend Activity"
        verbose_name_plural = "Friend Activities"
        constraints = [
            models.CheckConstraint(
                name="no self poke",
                check=~models.Q(toUserid=models.F("fromUserid"))
            )
        ]
