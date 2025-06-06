# Generated by Django 5.1.6 on 2025-04-05 07:57

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0022_gamecharacter_unique_selected_per_gamesave'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='gamecharacter',
            name='color_hex',
        ),
        migrations.AddField(
            model_name='friendactivity',
            name='details',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AddField(
            model_name='gamecharacter',
            name='class',
            field=models.CharField(choices=[('KNIGHT', 'Knight'), ('ARCHER', 'Archer'), ('PAWN', 'Pawn')], db_column='class', default='PAWN', max_length=6),
        ),
        migrations.AddField(
            model_name='gamecharacter',
            name='color',
            field=models.CharField(choices=[('RED', 'Red'), ('PURPLE', 'Purple'), ('YELLOW', 'Yellow'), ('BLUE', 'Blue')], default='RED', max_length=6),
        ),
        migrations.AddField(
            model_name='workoutrecord',
            name='activityid',
            field=models.ForeignKey(blank=True, db_column='activityid', default=None, null=True, on_delete=django.db.models.deletion.CASCADE, to='api.friendactivity'),
        ),
        migrations.AlterField(
            model_name='friendactivity',
            name='status',
            field=models.CharField(choices=[('ACC', 'Accept'), ('REJ', 'Reject'), ('CAN', 'Cancel'), ('EXP', 'Expired'), ('PEN', 'Pending'), ('ONG', 'Ongoing'), ('FIN', 'Finished')], default='PEN', max_length=3),
        ),
    ]
