# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Status(models.TextChoices):
    ONLINE = 'online'
    IDLE = 'idle'
    DND = 'do not disturb'


class Gender(models.TextChoices):
    MALE = 'Male'
    FEMALE = 'Female'
    OTHER = 'Other'


class User(models.Model):
    userid = models.AutoField(db_column='userID', primary_key=True)  # Field name made lowercase.
    username = models.CharField(unique=True, max_length=50)
    email = models.EmailField(unique=True, max_length=100)
    phonenumber = models.CharField(db_column='phoneNumber', max_length=15)  # Field name made lowercase.
    joindate = models.DateTimeField(db_column='joinDate', auto_now_add=True)  # Field name made lowercase.

    class Meta:
        db_table = 'users'


class UserActivity(models.Model):
    activityid = models.AutoField(db_column='activityID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    calories = models.IntegerField()
    steps = models.IntegerField()

    class Meta:
        db_table = 'user_activity'


class UserAuditLog(models.Model):
    logid = models.AutoField(db_column='logID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    action = models.CharField(max_length=50)
    details = models.TextField()
    timestamp = models.DateTimeField()

    class Meta:
        db_table = 'user_audit_log'


class UserAuth(models.Model):
    authid = models.AutoField(db_column='authID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    oauth2token = models.TextField(db_column='Oauth2token')  # Field name made lowercase.
    oauth2tokenexpiry = models.DateTimeField(db_column='Oauth2tokenExpiry', )  # Field name made lowercase.
    refreshtoken = models.TextField(db_column='refreshToken')  # Field name made lowercase.
    passwordhash = models.CharField(db_column='passwordHash', max_length=255)  # Field name made lowercase.

    class Meta:
        db_table = 'user_auth'


class UserProfiles(models.Model):
    profileid = models.AutoField(db_column='profileID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    firstname = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    dateofbirth = models.DateField(db_column='dateOfBirth')  # Field name made lowercase.
    gender = models.CharField(choices=Gender, max_length=6)
    address = models.TextField()
    height_cm = models.DecimalField(max_digits=5, decimal_places=2)
    weight_kg = models.DecimalField(max_digits=5, decimal_places=2)

    class Meta:
        db_table = 'user_profiles'


class UserSettings(models.Model):
    settingid = models.AutoField(db_column='settingID', primary_key=True)  # Field name made lowercase.
    userid = models.ForeignKey(User, models.CASCADE, db_column='userID')  # Field name made lowercase.
    status = models.CharField(choices=Status, max_length=14)

    class Meta:
        db_table = 'user_settings'
