# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib.auth.models import User
from django.db import models

from emogo.apps.stream.models import Stream
from emogo.lib.default_models.default_model import DefaultStatusModel


class Collaborator(DefaultStatusModel):
    name = models.CharField(max_length=45, null=True, blank=True)
    phone_number = models.CharField(max_length=45, null=True, blank=True)
    stream = models.ForeignKey(Stream, null=True, blank=True)
    can_add_content = models.BooleanField(default=False)
    can_add_people = models.BooleanField(default=False)
    created_by = models.ForeignKey(User, null=True, blank=True)

    class Meta:
        db_table = 'collaborator'
