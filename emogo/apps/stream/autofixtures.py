import autofixture
from autofixture import generators, AutoFixture
from emogo.lib.custom_generators.generators import CustomNameGenerator
from models import Stream, Content
import random
from emogo.apps.collaborator.autofixtures import CollaboratorAutoFixture
from emogo.apps.collaborator.models import Collaborator

class StreamAutoFixture(AutoFixture):
    """
    : class:`StreamAutoFixture` is automatically used by default to create new
        ``Stream`` instances.
    """

    def __init__(self, *args, **kwargs):
        self.num_of_instances = kwargs.pop('num_of_instances', None)
        self.created_by = kwargs.pop('user', None)
        if self.created_by:
            self.field_values['created_by'] = self.created_by
        super(StreamAutoFixture, self).__init__(*args, **kwargs)

    class Values(object):
        name = CustomNameGenerator(name_prefix='Stream')
        description = generators.LoremGenerator(max_length=20)
        category = None
        image = None
        type = generators.ChoicesGenerator(values=('Public', 'Private'))
        any_one_can_edit = generators.ChoicesGenerator(values=(True, False))
        view_count = generators.PositiveIntegerGenerator(max_value=200)
        featured = False
        emogo = False

    # don't follow permissions and groups
    follow_m2m = False

    def post_process_instance(self, instance, commit):
        # make sure user's last login was not before he joined
        if instance:
            CollaboratorAutoFixture(Collaborator, stream=instance, user=instance.created_by,
                                    field_values={"can_add_content": random.choice([True,False]),
                                                  "can_add_people": random.choice([True,False])},
                                    num_of_instances=self.num_of_instances).create(self.num_of_instances.get('collaborator'))
            ContentAutoFixture(Content, stream=instance, user=instance.created_by).create(self.num_of_instances.get('content'))
        return instance


class ContentAutoFixture(AutoFixture):
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
        super(ContentAutoFixture, self).__init__(*args, **kwargs)

    class Values(object):
        name = CustomNameGenerator(name_prefix='Content')
        description = generators.LoremGenerator(max_length=30)
        url = 'https://dummyimage.com/300/09f/fff.png'
        type_list = ['Video','Picture', 'Link', 'Giphy']
        type = generators.ChoicesGenerator(values=('Video', 'Picture', 'Link', 'Giphy'))
        video_image = None #'https://dummyimage.com/300/09f/fff.png' if type.get_value()=='Video' else None

    # don't follow permissions and groups
    follow_m2m = {'ALL': (1, 2)}

autofixture.register(Stream, StreamAutoFixture, fail_silently=True)
autofixture.register(Content, ContentAutoFixture, fail_silently=True)
