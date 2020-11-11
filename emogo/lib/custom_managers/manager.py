from django.db import models


class ActiveManager(models.Manager):
    """
    Custom ActiveManager Class to get Active record.
    """
    def get_queryset(self):
        return super(ActiveManager, self).get_queryset().filter(status='Active')


class UserActiveManager(models.Manager):
    """
    Custom UserActiveManager Class to get Active record.
    """
    def get_queryset(self):
        return super(UserActiveManager, self).get_queryset().filter(status='Active', user__is_active=True)

class CollabActiveManager(models.Manager):
    """
    Custom ActiveManager Class to get Active record.
    """
    def get_queryset(self):
        return super(CollabActiveManager, self).get_queryset().filter(status__in =['Active', 'Unverified'])
