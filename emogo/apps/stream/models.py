# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.contrib.auth.models import User

from django.conf import settings

STREAM_TYPE = (
    ('Private', 'Private'),
    ('Public', 'Public'),
)

CONTENT_TYPE = (
    ('Video', 'Video'),
    ('Picture', 'Picture'),
    ('Link', 'Link'),
)

EVENT_TYPE = (
    ('Stream', 'Stream'),
    ('Content', 'Content'),
)

class CategoryMaster( models.Model ):
    name = models.CharField(max_length=45, null=True, blank=True)
    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'category_master'

class Stream( models.Model ):
    name = models.CharField(max_length=45, null=True, blank=True)
    category_master = models.ForeignKey(CategoryMaster, null=True, blank=True)
    image = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10, choices=STREAM_TYPE, default=STREAM_TYPE[0][0])
    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)
    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'stream'

class Content( models.Model ):
    name = models.CharField(max_length=45, null=True, blank=True)
    url = models.CharField(max_length=45, null=True, blank=True)
    type = models.CharField(max_length=10, choices=CONTENT_TYPE, default=CONTENT_TYPE[0][0])
    stream = models.ForeignKey(Stream, null=True, blank=True)
    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)
    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'content'

class tags( models.Model ):
    name = models.CharField(max_length=45, null=True, blank=True)
    event_id = models.IntegerField(null=True, blank=True)
    event_type = models.CharField(max_length=10, choices=EVENT_TYPE, default=EVENT_TYPE[0][0])
    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)
    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'tags'
