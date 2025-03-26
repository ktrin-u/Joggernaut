import uuid

from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models

from api.validators import validate_phoneNumber


class Status(models.TextChoices):
    ONLINE = "online"
    IDLE = "idle"
    DND = "do not disturb"


class Gender(models.TextChoices):
    MALE = "Male"
    FEMALE = "Female"
    OTHER = "Other"


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
            lastname=lastname,
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
    userid = models.UUIDField(
        db_column="userID",
        primary_key=True,
        unique=True,
        default=uuid.uuid4,
        editable=False,
    )
    email = models.EmailField(unique=True, max_length=100)
    phonenumber = models.CharField(
        db_column="phoneNumber",
        max_length=15,
        validators=[validate_phoneNumber],
        unique=True,
    )  # Field name made lowercase.
    firstname = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    joindate = models.DateTimeField(
        db_column="joinDate", auto_now_add=True
    )  # Field name made lowercase.
    first_name = None
    last_name = None
    username = None
    date_joined = None

    objects = UserManager()  # type: ignore

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["phonenumber", "firstname", "lastname"]

    class Meta:
        db_table = "users"
        ordering = ["userid"]
        verbose_name = "user"

    def ban(self):
        self.is_active = False

    def unban(self):
        self.is_active = True


class UserAuditLog(models.Model):
    logid = models.AutoField(db_column="logID", primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(
        User, models.CASCADE, db_column="userID"
    )  # Field name made lowercase.
    action = models.CharField(max_length=50)
    details = models.TextField()
    timestamp = models.DateTimeField()

    class Meta:
        db_table = "user_audit_log"
        verbose_name = "user audit log"
        verbose_name_plural = "user audit logs"


class UserProfiles(models.Model):
    # profileid = models.AutoField(db_column='profileID', primary_key=True)  # Field name made lowercase.
    # userid = models.ForeignKey(User, models.CASCADE, db_column='userID', unique=True)  # Field name made lowercase.
    userid = models.OneToOneField(
        User, on_delete=models.CASCADE, db_column="userID", primary_key=True
    )
    accountname = models.CharField(unique=True, max_length=50)
    dateofbirth = models.DateField(db_column="dateOfBirth")  # Field name made lowercase.
    gender = models.CharField(choices=Gender, max_length=6)
    address = models.TextField()
    height_cm = models.DecimalField(max_digits=5, decimal_places=2)
    weight_kg = models.DecimalField(max_digits=5, decimal_places=2)

    class Meta:
        db_table = "user_profiles"
        verbose_name = "user profile"
        verbose_name_plural = "user profiles"


class UserSettings(models.Model):
    # settingid = models.AutoField(db_column='settingID', primary_key=True)  # Field name made lowercase.
    userid = models.OneToOneField(
        User, models.CASCADE, db_column="userID", primary_key=True
    )  # Field name made lowercase.
    status = models.CharField(choices=Status, max_length=14)

    class Meta:
        db_table = "user_settings"
        verbose_name = "user settings"
        verbose_name_plural = "user settings"
