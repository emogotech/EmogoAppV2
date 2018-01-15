import autofixture
from autofixture import generators, AutoFixture
from emogo.lib.custom_generators.generators import CustomNameGenerator
from models import Collaborator
import random
from emogo.lib.custom_generators.generators import PhoneNumberGenerator


class CollaboratorAutoFixture(AutoFixture):
    """
    : class:`StreamAutoFixture` is automatically used by default to create new
        ``Stream`` instances.
    """

    def __init__(self, *args, **kwargs):
        self.num_of_instances = kwargs.pop('num_of_instances', None)
        self.created_by = kwargs.pop('user', None)
        self.stream = kwargs.pop('stream', None)
        if self.created_by:
            self.field_values['created_by'] = self.created_by
        if self.stream:
            self.field_values['stream'] = self.stream
        super(CollaboratorAutoFixture, self).__init__(*args, **kwargs)

    class Values(object):
        name = CustomNameGenerator(name_prefix='Collaborator')
        phone_number = PhoneNumberGenerator(country_code='+91')
        # permission_choice = [True, False]
        # can_add_content = random.choice(permission_choice)
        # can_add_people = random.choice(permission_choice)
        image = None

    # don't follow permissions and groups
    follow_m2m = False

autofixture.register(Collaborator, CollaboratorAutoFixture, fail_silently=True)
