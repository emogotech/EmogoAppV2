# -*- coding: utf-8 -*-#
# from future import unicode_literals
from django.conf import settings
from django.db import models

from emogo.lib.custom_managers.custom_manager import ActiveManager


class DefaultDateModel(models.Model):
    """ Abstract model class to created_at and updated_at fields """

    crd = models.DateTimeField(auto_now_add=True)
    upd = models.DateTimeField(auto_now_add=True)

    class Meta:
        abstract = True


class DefaultStatusModel(DefaultDateModel):
    """ Abstract Model for status field"""

    status = models.CharField(max_length=10, choices=settings.STATUSES, default=settings.STATUSES[0][0])
    objects = models.Manager()  # The default manager.
    actives = ActiveManager()  # The custom Active manager.

    class Meta:
        abstract = True
