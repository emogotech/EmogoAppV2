from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from emogo.apps.users.autofixtures import UserAutoFixture


class Command(BaseCommand):
    help = 'Closes the specified poll for voting'

    def add_arguments(self, parser):
        parser.add_argument('-user', type=int, nargs='?', default=1)
        parser.add_argument('-company', type=int, nargs='?', default=1)
        parser.add_argument('-budget', type=int , nargs='?', default=2)
        parser.add_argument('-goal', type=int, nargs='?', default=2)
        parser.add_argument('-goal_allocation', type=int, nargs='?', default=2)
        parser.add_argument('-campaign', type=int, nargs='?', default=2)
        parser.add_argument('-campaign_allocation', type=int, nargs='?', default=2)
        parser.add_argument('-program', type=int, nargs='?', default=2)
        parser.add_argument('-program_allocation', type=int, nargs='?', default=2)
        parser.add_argument('-expense', type=int, nargs='?', default=2)
        parser.add_argument('-expense_allocation', type=int, nargs='?', default=2)

        parser.add_argument('-tags', type=int, nargs='?', default=2)
        parser.add_argument('-tags_mapping', type=int, nargs='?', default=2)

        parser.add_argument('-metric', type=int, nargs='?', default=2)
        parser.add_argument('-metric_mapping', type=int, nargs='?', default=2)


        parser.add_argument('-company_budget_alloc', type=int, nargs='?', default=12)
        parser.add_argument('-company_segment_type_alloc', type=int, nargs='?', default=2)
        parser.add_argument('-company_budget_segment', type=int, nargs='?', default=4)
        parser.add_argument('-company_budget_segment_amount', type=int, nargs='?', default=10)


    def handle(self, *args, **options):
        print(options)
        # BudgetAutoFixture(Budget,num_of_instances = options).create(options['budget'])
        UserAutoFixture(User,num_of_instances = options).create(options['user'])
