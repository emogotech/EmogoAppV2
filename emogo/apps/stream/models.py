# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.contrib.auth.models import User
from django.db import models
from emogo.lib.default_models.default_model import DefaultStatusModel
import itertools

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


class CategoryMaster(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)

    class Meta:
        db_table = 'category_master'


class Stream(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)
    description = models.TextField(max_length=1000, null=True, blank=True)
    category = models.ForeignKey(CategoryMaster, null=True, blank=True)
    image = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10, choices=STREAM_TYPE, default=STREAM_TYPE[0][0])
    any_one_can_edit = models.BooleanField(default=False)
    created_by = models.ForeignKey(User, null=True, blank=True)

    class Meta:
        db_table = 'stream'

    def delete(self, using=None, keep_parents=False):
        collaborators = self.collaborator_list.filter(status='Active')
        contents = self.content_list.filter(status='Active')
        # Delete collaborators
        map(self.update_status, collaborators,itertools.repeat('Inactive', collaborators.__len__()))
        # Delete Contents
        map(self.update_status, contents, itertools.repeat('Inactive', contents.__len__()))
        # Delete stream
        self.update_status(self,'Inactive')
        return None

    def update_status(self, instance, status):
        instance.status = status
        instance.save(update_fields=['status'])

class Content(DefaultStatusModel):
    name = models.CharField(max_length=75, null=True, blank=True)
    url = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10, choices=CONTENT_TYPE, default=CONTENT_TYPE[0][0])
    stream = models.ForeignKey(Stream, null=True, blank=True, related_name='content_list')
    created_by = models.ForeignKey(User, null=True, blank=True)

    class Meta:
        db_table = 'content'


class Tags(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)
    event_id = models.IntegerField(null=True, blank=True)
    event_type = models.CharField(max_length=10, choices=EVENT_TYPE, default=EVENT_TYPE[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)

    class Meta:
        db_table = 'tags'
