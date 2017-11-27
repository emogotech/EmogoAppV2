# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.models import User
from django.db import models

from emogo.lib.default_models.default_model import DefaultDateModel, DefaultStatusModel

DEVICE_TYPE = (
    ('Android', 'Android'),
    ('Iphone', 'Iphone'),
)

MESSAGE_STATUS = (
    ('Complete', 'Complete'),
    ('Incomplete', 'Incomplete'),
)


class UserProfile(DefaultStatusModel):
    full_name = models.CharField(max_length=45, null=True, blank=True)
    country_code = models.CharField(max_length=5, null=True, blank=True)
    user_image = models.CharField(max_length=255, null=True, blank=True)
    is_admin = models.BooleanField(default=False)
    user = models.OneToOneField(User, null=True, blank=True, related_name="user_data")
    otp = models.CharField(max_length=10, null=True, blank=True)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'user_profile'


class UserDevice(DefaultDateModel):
    user = models.ForeignKey(User, null=True, blank=True)
    type = models.CharField(max_length=10, choices=DEVICE_TYPE, default=DEVICE_TYPE[0][0])
    is_device_enable = models.BooleanField(default=False)
    udid = models.CharField(max_length=80, null=True, blank=True)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'user_device'


class UserNotification(DefaultDateModel):
    status = models.CharField(max_length=10, choices=MESSAGE_STATUS, default=MESSAGE_STATUS[0][0])
    device = models.ForeignKey(UserDevice, null=True, blank=True)

    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'user_notification'
