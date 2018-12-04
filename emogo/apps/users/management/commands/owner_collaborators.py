from django.core.management.base import BaseCommand
from django.contrib.auth.models import User

from emogo.apps.stream.models import *
from emogo.apps.collaborator.models import Collaborator

class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def handle(self, *args, **options):
        # Get all Streams data
        streams = Stream.objects.all()
        for stream in streams:
          # Check Owner is present or stream have any collabrators or not.
          if stream.collaborator_list.all().__len__() > 0 and stream.created_by.username not in map(lambda x: x.phone_number, stream.collaborator_list.all()) :
            #Find user instance by stream created_by
            user_qs = User.objects.filter(id = stream.created_by.id).values('user_data__full_name', 'username')
            #Find and create stream's collaborator as owner
            collaborator, created = Collaborator.objects.get_or_create(
                phone_number=user_qs[0].get('username'),
                stream=stream,
                name = user_qs[0].get('user_data__full_name'),
                can_add_content = True,
                can_add_people = True,
                created_by = stream.created_by
            )
            print("Owner Collaborator Saved Successfully and return true%s", collaborator.id)