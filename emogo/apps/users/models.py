# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.models import User
from django.db import models
from emogo.apps.stream.models import Stream, Content
from emogo.apps.collaborator.models import Collaborator
import requests
import json
from emogo.lib.default_models.models import DefaultDateModel, DefaultStatusModel, UsersStatusModel
from django.utils.translation import ugettext_lazy as _
import branchio
from emogo import settings
import rest_framework.authtoken.models

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
    display_name = models.CharField(max_length=75, null=True, blank=True)
    country_code = models.CharField(max_length=5, null=True, blank=True)
    user_image = models.CharField(max_length=255, null=True, blank=True)
    is_admin = models.BooleanField(default=False)
    user = models.OneToOneField(User, null=True, blank=True, related_name="user_data")
    otp = models.CharField(max_length=10, null=True, blank=True)
    location = models.CharField(max_length=50, null=True, blank=True)
    website = models.CharField(max_length=250, null=True, blank=True)
    biography = models.CharField(max_length=255, null=True, blank=True)
    birthday = models.CharField(max_length=15, null=True, blank=True)
    branchio_url = models.CharField(max_length=75, null=True, blank=True)
    profile_stream = models.ForeignKey(Stream, null=True, blank=True)
    is_buisness_account = models.BooleanField(default=False)
    is_suggested = models.BooleanField(default=False)


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
    type = models.CharField(max_length=10, choices=DEVICE_TYPE, default=DEVICE_TYPE[1][0])
    is_device_enable = models.BooleanField(default=False)
    device_token = models.TextField(null=True)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'user_device'

class UserOnlineStatus(models.Model):
    stream = models.ForeignKey(Stream, related_name="user_online_stream")
    user_device = models.ForeignKey(UserDevice, related_name="user_online_device")


class UserNotification(DefaultDateModel):
    status = models.CharField(max_length=10, choices=MESSAGE_STATUS, default=MESSAGE_STATUS[0][0])
    device = models.ForeignKey(UserDevice, null=True, blank=True)

    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'user_notification'


# Create branch deep link
def create_user_deep_link(user):
    client = branchio.Client(settings.branch_key)
    response = client.create_deep_link_url(
        channel="Emogo", data={
            "user_full_name": user.user_data.full_name,
            "user_image": user.user_data.user_image,
            "user_id": user.user_data.id,
            "$ios_url": settings.DATA_BRANCH_IOS_URL,
            "location": user.user_data.location,
            "website": user.user_data.website,
            "birthday": user.user_data.birthday,
            "biography": user.user_data.biography,
            "phone": user.username
        }

    )
    user.user_data.branchio_url = response.get('url')
    user.user_data.save()
    return response.get('url')


def update_user_deep_link_url(user):
    data = {
        "branch_key": settings.branch_key,
        "branch_secret": settings.branch_secret,
        "channel": "Emogo",
        "data": {
            "user_full_name": user.user_data.full_name,
            "user_image": user.user_data.user_image,
            "user_id": user.user_data.id,
            "$ios_url": settings.DATA_BRANCH_IOS_URL,
            "location": user.user_data.location,
            "website": user.user_data.website,
            "birthday": user.user_data.birthday,
            "biography": user.user_data.biography,
            "phone": user.username
        }
    }
    if user.user_data.branchio_url is not None:
        url = 'https://api.branch.io/v1/url?url={0}'.format(user.user_data.branchio_url)
        headers = {'Content-Type': 'application/json'}
        response = requests.put(url, data=json.dumps(data), headers=headers)
        if json.loads(response.text).get('data') is not None:
            user.user_data.branchio_url = json.loads(response.text).get('data').get('url')
            user.user_data.save()
    else:
        create_user_deep_link(user)
    return True


class UserFollow(models.Model):
    following = models.ForeignKey(User, related_name="who_follows")
    follower = models.ForeignKey(User, related_name="who_is_followed")
    follow_time = models.DateTimeField(auto_now=True)
    objects = models.Manager()  # The default manager.

    def __unicode__(self):
        return str(self.follow_time)

    class Meta:
        db_table = 'user_follow'
 
 
class Token(rest_framework.authtoken.models.Token):
    # key is no longer primary key, but still indexed and unique
    key = models.CharField(_("Key"), max_length=40, db_index=True, unique=True)
    # relation to user is a ForeignKey, so each user can have more than one token
    user = models.ForeignKey(
        User, related_name='auth_tokens',
        on_delete=models.CASCADE, verbose_name=_("User")
    )
    device_name = models.CharField(_("Device Name"), max_length=90, null=True, blank=True)
 
    # class Meta:
    #     unique_together = (('user', 'name'),)