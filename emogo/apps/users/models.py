# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.models import User
from django.db import models
from emogo.apps.stream.models import Stream, Content
from emogo.apps.collaborator.models import Collaborator

from emogo.lib.default_models.models import DefaultDateModel, DefaultStatusModel, UsersStatusModel

DEVICE_TYPE = (
    ('Android', 'Android'),
    ('Iphone', 'Iphone'),
)

MESSAGE_STATUS = (
    ('Complete', 'Complete'),
    ('Incomplete', 'Incomplete'),
)


class UserProfile(UsersStatusModel):
    full_name = models.CharField(max_length=45, null=True, blank=True)
    country_code = models.CharField(max_length=5, null=True, blank=True)
    user_image = models.CharField(max_length=255, null=True, blank=True)
    is_admin = models.BooleanField(default=False)
    user = models.OneToOneField(User, null=True, blank=True, related_name="user_data")
    otp = models.CharField(max_length=10, null=True, blank=True)

    class Meta:
        db_table = 'user_profile'

    def user_streams(self):
        """
        :return: The function will return all streams created by user.
        """
        return self.user.stream_set.model.actives.filter(created_by=self.user)

    def user_contents(self):
        """
        :return: The function will return all Contents created by user.
        """
        return self.user.content_set.model.actives.filter(created_by=self.user)

    def user_as_collaborators(self):
        return Collaborator.actives.filter(phone_number=self.user.username, stream__status='Active')


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
