from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from emogo.apps.users.models import UserFollow
from emogo.apps.users.autofixtures import UserAutoFixture, UserFollowAutoFixture
from emogo.apps.stream.models import Stream, Content, StreamContent, LikeDislikeContent, LikeDislikeStream
from emogo.apps.stream.autofixtures import StreamAutoFixture, ContentAutoFixture, StreamContentAutoFixture, LikeDislikeStreamAutoFixture, LikeDislikeContentAutoFixture
from emogo.apps.collaborator.autofixtures import CollaboratorAutoFixture
from emogo.apps.collaborator.models import Collaborator

class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def add_arguments(self, parser):
        parser.add_argument('-user', type=int, nargs='?', default=1)
        parser.add_argument('-stream', type=int, nargs='?', default=3)
        parser.add_argument('-content', type=int , nargs='?', default=3)
        parser.add_argument('-collaborator', type=int, nargs='?', default=5)

    def handle(self, *args, **options):
        # print(options)
        # UserAutoFixture(User, num_of_instances=options).create(options['user'])
        # StreamAutoFixture(Stream).create(250)
        # ContentAutoFixture(Content).create(1000)
        # StreamContentAutoFixture(StreamContent).create(3000)
        # CollaboratorAutoFixture(Collaborator).create(200)
        # LikeDislikeStreamAutoFixture(LikeDislikeStream).create(200)
        # LikeDislikeContentAutoFixture(LikeDislikeContent).create(3000)
        UserFollowAutoFixture(UserFollow).create(5000)