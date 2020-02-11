from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from emogo.apps.collaborator.models import Collaborator
import csv

class Command(BaseCommand):
    help = 'Update user entry for collaborator.'

    def handle(self, *args, **options):
        # Get all Collaborators data whose phone number length is greater than 10
        collaborators = Collaborator.objects.filter(phone_number__gte=10)
        for collaborator in collaborators:
            try:
                # Get user whose username is same as collaborators number
                user = User.objects.get(username__endswith=collaborator.phone_number[-10:], username__gte=10)
                collaborator.user = user
                collaborator.save()
            except:
                pass