from django.db import models


class ActiveManager(models.Manager):
    """
    Custom ActiveManager Class to get Active record.
    """
    def get_queryset(self):
        return super(ActiveManager, self).get_queryset().filter(status='Active')
