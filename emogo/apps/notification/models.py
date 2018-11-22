# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.db import models
from django.contrib.auth.models import User

from emogo.apps.stream.models import Stream, Content
from emogo.lib.default_models.models import DefaultDateModel

# Create your models here.
NOTIFICATION_TYPE = (
    ('liked_emogo', '{0} liked your {1}'),
    ('follower', '{0} started following you'),
    ('collaborator_confirmation', '{0} added you to {1}'),
    ('accepted', '{0} accepted your {1} request'),
    ('joined', 'You joined {0}'),
    ('liked_content', '{0} loved your {1}'),
    ('add_content', '{0} added to {1}'),
    ('self', 'You saved {0} items'),
    ('decline', 'You declined to join {0}'),
    ('deleted_collaborator', 'This collaboration does not exists anymore'),
    ('deleted_stream', 'This {0} does not exists anymore'),
)

class Notification(DefaultDateModel):
    notification_type = models.CharField(max_length=50, choices=NOTIFICATION_TYPE, null=True, blank=True)
    from_user = models.ForeignKey(User, related_name="sender")
    to_user = models.ForeignKey(User, related_name="receiver")
    stream = models.ForeignKey(Stream, null=True, blank=True)
    content = models.ForeignKey(Content, null=True, blank=True)
    content_lists = models.TextField(null=True, blank=True)
    content_count = models.IntegerField(default=0, blank=True, null=True)
    is_open = models.BooleanField(default=True)

    class Meta:
        db_table = 'notification'