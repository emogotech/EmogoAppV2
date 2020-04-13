# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.models import User
from django.db import models

from emogo.apps.stream.models import Stream
from emogo.lib.default_models.models import DefaultStatusModel


class Collaborator(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)
    phone_number = models.CharField(max_length=45, null=True, blank=True)
    stream = models.ForeignKey(Stream, null=True, blank=True, related_name='collaborator_list')
    can_add_content = models.BooleanField(default=False)
    can_add_people = models.BooleanField(default=False)
    image = models.CharField(max_length=200, null=True, blank=True, default="")
    created_by = models.ForeignKey(User, null=True, blank=True)
    # deleted_by = models.CharField(max_length=15, choices=DELETED_TYPE, default=DELETED_TYPE[0][0])


    class Meta:
        db_table = 'collaborator'

