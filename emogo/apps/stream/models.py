# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.contrib.auth.models import User
from django.db import models
from emogo.lib.default_models.models import DefaultStatusModel, DefaultDateModel
import itertools
from django.db.models.signals import post_save
from django.dispatch import receiver
from datetime import datetime

STREAM_TYPE = (
    ('Private', 'Private'),
    ('Public', 'Public'),
)

CONTENT_TYPE = (
    ('Video', 'Video'),
    ('Picture', 'Picture'),
    ('Link', 'Link'),
    ('Giphy', 'Giphy'),
    ('Note', 'Note')

)

EVENT_TYPE = (
    ('Stream', 'Stream'),
    ('Content', 'Content'),
)

CHOICE_TYPE = (
    (0, 'Like'),
    (1, 'Dislike')
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
    name = models.CharField(max_length=75, null=True, blank=True)
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
    have_some_update = models.BooleanField(default=False)
    color = models.CharField(max_length=50, null=True, blank=True, default=None)

    class Meta:
        db_table = 'stream'

    def delete(self, using=None, keep_parents=False):
        collaborators = self.collaborator_list(manager='actives').all()
        self.stream_contents.all().delete()
        # Delete collaborators
        map(self.update_status, collaborators, itertools.repeat('Inactive', collaborators.__len__()))

        # Delete stream
        self.update_status(self, 'Inactive')
        return None

    def update_status(self, instance, status):
        instance.status = status
        instance.save(update_fields=['status'])

    # def update_view_count(self):
    #     # Update view count increment by 1
    #     self.view_count += 1
    #     self.save()
    #     return self.view_count


class Content(DefaultStatusModel):
    name = models.CharField(max_length=75, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    url = models.TextField(max_length=1000, null=True, blank=True)
    type = models.CharField(max_length=10, choices=CONTENT_TYPE, default=CONTENT_TYPE[0][0])
    video_image = models.CharField(max_length=255, null=True, blank=True)
    streams = models.ManyToManyField(Stream, through='StreamContent')
    created_by = models.ForeignKey(User, null=True, blank=True)
    height = models.CharField(max_length=10, null=True, blank=True, default=300)
    width = models.CharField(max_length=10, null=True, blank=True, default=300)
    color = models.CharField(max_length=10, null=True, blank=True, default=None)
    order = models.IntegerField(default=0, blank=True, null=True)

    class Meta:
        db_table = 'content'


class StreamContent(models.Model):
    stream = models.ForeignKey(Stream, related_name='stream_contents')
    content = models.ForeignKey(Content, related_name='content_streams')
    attached_date = models.DateTimeField(auto_now_add=True)
    order = models.IntegerField(default=0, blank=True, null=True)
    user = models.ForeignKey(User, blank=True, null=True)
    thread = models.CharField(max_length=45, null=True, blank=True)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'stream_content'


class StreamUserViewStatus(models.Model):
    stream = models.ForeignKey(Stream, related_name='stream_user_view_status')
    action_date = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'stream_user_view_status'


class LikeDislikeStream(models.Model):
    stream = models.ForeignKey(Stream, related_name='stream_like_dislike_status')
    view_date = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User, blank=True, null=True)
    status = models.CharField(max_length=5, choices=CHOICE_TYPE, default=0)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'like_dislike_stream'


class LikeDislikeContent(models.Model):
    content = models.ForeignKey(Content, related_name='content_like_dislike_status')
    view_date = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(User, blank=True, null=True)
    status = models.CharField(max_length=5, choices=CHOICE_TYPE, default=0)
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'like_dislike_content'

@receiver(post_save, sender=StreamContent)
def save_profile(sender, instance, **kwargs):
    instance.stream.upd = datetime.now()
    instance.stream.save()


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


class RecentUpdates(models.Model):
    """
    Recent update table model class.
    """
    user = models.ForeignKey(User, blank=True, null=True)
    stream = models.ForeignKey(Stream, null=True, blank=True, related_name='recent_stream')
    thread = models.CharField(max_length=45, null=True, blank=True)
    seen_index = models.IntegerField(null=True, blank=True)

    class Meta:
        db_table = 'recent_updates'


class StarredStream(DefaultStatusModel):
    user = models.ForeignKey(User, blank=True, null=True)
    stream = models.ForeignKey(Stream, related_name='stream_starred')
    view_date = models.DateTimeField(auto_now_add=True)
    crd = None  # Made parent field as None.
    upd = None
    objects = models.Manager()  # The default manager.

    class Meta:
        db_table = 'starred_stream';
