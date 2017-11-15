# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.contrib.auth.models import User
from django.conf import settings
from emogo.apps.stream.models import Stream

class Collaborator( models.Model ):
    name = models.CharField(max_length=45, null=True, blank=True)
    phone_number = models.CharField(max_length=45, null=True, blank=True)
    stream = models.ForeignKey(Stream, null=True, blank=True)
    can_add_content = models.BooleanField(default=False)
    can_add_people = models.BooleanField(default=False)
    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    created_by = models.ForeignKey(User, null=True, blank=True)
    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'collaborator'
