# Generated by Django 5.1.6 on 2025-03-09 09:41

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0011_friendtable'),
    ]

    operations = [
        migrations.AlterField(
            model_name='friendtable',
            name='status',
            field=models.CharField(choices=[('PEN', 'Pending'), ('ACC', 'Accepted')], default='PEN', max_length=3),
        ),
        migrations.DeleteModel(
            name='UserActivity',
        ),
    ]
