from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from emogo.apps.collaborator.models import Collaborator
import csv
from django.db.models.functions import Length
from django.db.models import Q
from django.core.exceptions import MultipleObjectsReturned, ObjectDoesNotExist


class Command(BaseCommand):
    help = 'Update user entry for collaborator.'

    def handle(self, *args, **options):
        # Get all Collaborators data whose phone number length is greater than 10
        collaborators = Collaborator.objects.annotate(phone_length=Length('phone_number')).filter(phone_length__gte=10)
        for collaborator in collaborators:
            try:
                # Get user whose username is same as collaborators number
                user = User.objects.get(username__endswith=collaborator.phone_number[-10:])
                collaborator.user = user
                collaborator.save()
            except MultipleObjectsReturned:
                pass
            except ObjectDoesNotExist:
                # user = User.objects.get(username__startswith=collaborator.phone_number[-10:])
                print(collaborator.phone_number, 'Not found')