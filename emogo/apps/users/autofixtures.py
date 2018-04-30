import autofixture
from autofixture import generators , AutoFixture
from django.utils import timezone
from django.contrib.auth.hashers import make_password
from models import UserProfile, UserFollow
from autofixture.autofixtures import UserFixture
from emogo.lib.custom_generators.generators import PhoneNumberGenerator
from emogo.apps.stream.autofixtures import StreamAutoFixture
from emogo.apps.stream.models import Stream
from datetime import datetime, timedelta

class UserAutoFixture(UserFixture):
    """
    :   class:`UserFixture` is automatically used by default to create new
        ``User`` instances. It uses the following values to assure that you can
        use the generated instances without any modification:
        * ``username`` only contains chars that are allowed by django's auth forms.
        * ``email`` is unique.
        * ``first_name`` and ``last_name`` are single, random words of the lorem
          ipsum text.
        * ``is_staff`` and ``is_superuser`` are always ``False``.
        * ``is_active`` is always ``True``.
        * ``date_joined`` and ``last_login`` are always in the past and it is
          assured that ``date_joined`` will be lower than ``last_login``.
    """

    def __init__(self, *args, **kwargs):
        """
        By default the password is set to an unusable value, this makes it
        impossible to login with the generated users. If you want to use for
        example ``autofixture.create_one('auth.User')`` in your unittests to have
        a user instance which you can use to login with the testing client you
        can provide a ``username`` and a ``password`` argument. Then you can do
        something like::

            autofixture.create_one('auth.User', username='foo', password='bar`)
            self.client.login(username='foo', password='bar')
        """
        self.username = kwargs.pop('username', None)
        self.password = 12345
        self.num_of_instances = kwargs.pop('num_of_instances', None)
        super(UserAutoFixture, self).__init__(*args, **kwargs)

    class Values(object):
        username = PhoneNumberGenerator(country_code='+1')
        first_name = generators.FirstNameGenerator(1)
        last_name = generators.LastNameGenerator()
        password = staticmethod(lambda: make_password('123456'))
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
        if instance:
            UserProfileAutoFixture(UserProfile, user=instance, full_name=(instance.first_name+' '+instance.last_name)).create(1)
            # StreamAutoFixture(Stream, user=instance, num_of_instances = self.num_of_instances).create(self.num_of_instances.get('stream'))
        return instance


class UserProfileAutoFixture(AutoFixture):
    """
        :class:`UserProfileAutoFixture` is automatically used by default to create new
        ``UserProfile`` instances. It uses the following values to assure that you can
        use the generated instances without any modification:
    """

    # don't follow permissions and groups
    follow_m2m = False

    def __init__(self, *args, **kwargs):

        self.user = kwargs.pop('user', None)
        self.full_name = kwargs.pop('full_name', None)
        self.company = kwargs.pop('company', None)
        super(UserProfileAutoFixture, self).__init__(*args, **kwargs)
        if self.user:
            self.field_values['user'] = self.user
        if self.full_name:
            self.field_values['full_name'] = self.full_name
            self.field_values['display_name'] = self.full_name
        self.field_values['otp'] = None
        self.field_values['country_code'] = None
        self.field_values['branchio_url'] = None
        self.field_values['birthday'] = generators.DateGenerator()
        self.field_values['user_image'] = None
        self.field_values['location'] = 'USA'
        self.field_values['website'] = 'Not available'


class UserFollowAutoFixture(AutoFixture):
    """
        :class:`UserProfileAutoFixture` is automatically used by default to create new
        ``UserProfile`` instances. It uses the following values to assure that you can
        use the generated instances without any modification:
    """

    # don't follow permissions and groups
    follow_m2m = False

    def __init__(self, *args, **kwargs):

        self.user = kwargs.pop('user', None)
        self.full_name = kwargs.pop('full_name', None)
        self.company = kwargs.pop('company', None)
        super(UserFollowAutoFixture, self).__init__(*args, **kwargs)

    follow_fk = True


autofixture.register(UserProfile, UserProfileAutoFixture, fail_silently=True)
autofixture.register(UserFollow, UserFollowAutoFixture, fail_silently=True)