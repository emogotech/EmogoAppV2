from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from emogo.apps.users.autofixtures import UserAutoFixture


class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def add_arguments(self, parser):
        parser.add_argument('-user', type=int, nargs='?', default=1)
        parser.add_argument('-stream', type=int, nargs='?', default=3)
        parser.add_argument('-content', type=int , nargs='?', default=3)
        parser.add_argument('-collaborator', type=int, nargs='?', default=5)

    def handle(self, *args, **options):
        print(options)
        # BudgetAutoFixture(Budget,num_of_instances = options).create(options['budget'])
        UserAutoFixture(User, num_of_instances=options).create(1)
