# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.contrib.auth.models import User
from django.db import models
from emogo.lib.default_models.models import DefaultStatusModel, DefaultDateModel
import itertools

STREAM_TYPE = (
    ('Private', 'Private'),
    ('Public', 'Public'),
)

CONTENT_TYPE = (
    ('Video', 'Video'),
    ('Picture', 'Picture'),
    ('Link', 'Link'),
    ('Giphy', 'Giphy')

)

EVENT_TYPE = (
    ('Stream', 'Stream'),
    ('Content', 'Content'),
)

EXTREMIST_TYPE = (
    ('Inappropriate', 'Inappropriate'),
    ('Spam', 'Spam'),
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
    view_count = models.IntegerField(null=True, blank=True, default=0)
    featured = models.BooleanField(default=False)
    emogo = models.BooleanField(default=False)
    height = models.CharField(max_length=10, null=True, blank=True, default=300)
    width = models.CharField(max_length=10, null=True, blank=True, default=300)

    class Meta:
        db_table = 'stream'

    def delete(self, using=None, keep_parents=False):
        collaborators = self.collaborator_list(manager='actives').all()
        contents = self.content_set(manager='actives').all()
        # Delete collaborators
        map(self.update_status, collaborators, itertools.repeat('Inactive', collaborators.__len__()))
        # Delete Contents
        map(self.update_status, contents, itertools.repeat('Inactive', contents.__len__()))
        # Delete stream
        self.update_status(self, 'Inactive')
        return None

    def update_status(self, instance, status):
        instance.status = status
        instance.save(update_fields=['status'])

    def update_view_count(self):
        # Update view count increment by 1
        self.view_count += 1
        self.save()
        return self.view_count


class Content(DefaultStatusModel):
    name = models.CharField(max_length=75, null=True, blank=True)
    description = models.CharField(max_length=255, null=True, blank=True)
    url = models.CharField(max_length=255, null=True, blank=True)
    type = models.CharField(max_length=10, choices=CONTENT_TYPE, default=CONTENT_TYPE[0][0])
    video_image = models.CharField(max_length=255, null=True, blank=True)
    streams = models.ManyToManyField(Stream)
    created_by = models.ForeignKey(User, null=True, blank=True)
    height = models.CharField(max_length=10, null=True, blank=True, default=300)
    width = models.CharField(max_length=10, null=True, blank=True, default=300)
    color = models.CharField(max_length=10, null=True, blank=True, default=None)

    class Meta:
        db_table = 'content'


class Tags(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)
    event_id = models.IntegerField(null=True, blank=True)
    event_type = models.CharField(max_length=10, choices=EVENT_TYPE, default=EVENT_TYPE[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)

    class Meta:
        db_table = 'tags'


class ExtremistReport(DefaultDateModel):
    objects = models.Manager()  # The default manager.

    content = models.ForeignKey(Content, null=True, blank=True, related_name='extremist_content')
    user = models.ForeignKey(User, null=True, blank=True, related_name='extremist_users')
    stream = models.ForeignKey(Stream, null=True, blank=True, related_name='extremist_streams')
    user_comment = models.TextField(max_length=900, null=True, blank=True)
    created_by = models.ForeignKey(User, null=True, blank=True)
    type = models.CharField(max_length=15, choices=EXTREMIST_TYPE, default=EXTREMIST_TYPE[0][0])

    class Meta:
        db_table = 'extremist_report'
