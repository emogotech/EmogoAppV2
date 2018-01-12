import autofixture
from autofixture import generators, AutoFixture
from django.utils import timezone
from django.contrib.auth.hashers import make_password
from autofixture.autofixtures import UserFixture
from emogo.lib.custom_generators.generators import PhoneNumberGenerator, CustomNameGenerator


class StreamAutoFixture(UserFixture):
    """
    : class:`StreamAutoFixture` is automatically used by default to create new
        ``Stream`` instances.
    """

    def __init__(self, *args, **kwargs):
        self.num_of_instances = kwargs.pop('num_of_instances', None)
        super(UserFixture, self).__init__(*args, **kwargs)

    class Values(object):
        name = CustomNameGenerator(name_prefix='Stream')
        description = generators.LoremGenerator(max_length=20)
        category = None
        last_name = generators.LastNameGenerator()
        password = staticmethod(lambda: make_password('123456'))


        # image
        # type
        # any_one_can_edit
        # created_by
        # view_count
        # featured
        # emogo
        # height
        # width
        is_active = True
        # don't generate admin users
        is_staff = False
        is_superuser = False
        date_joined = generators.DateTimeGenerator(max_date=timezone.now())
        last_login = generators.DateTimeGenerator(max_date=timezone.now())

    # don't follow permissions and groups
    follow_m2m = False

    def post_process_instance(self, instance, commit):
        # make sure user's last login was not before he joined
        # if instance:
        #     UserProfileAutoFixture(UserProfile, user=instance, full_name=(instance.first_name+' '+instance.last_name)).create(1)

        return instance


