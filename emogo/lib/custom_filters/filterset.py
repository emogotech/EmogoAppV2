import django_filters
from emogo.apps.stream.models import Stream
from emogo.apps.users.models import UserProfile
from django.db.models import Q


class StreamFilter(django_filters.FilterSet):
    my_stream = django_filters.filters.BooleanFilter(method='filter_my_stream')
    popular = django_filters.filters.BooleanFilter(method='filter_popular')

    class Meta:
        model = Stream
        fields = ['featured', 'emogo', 'my_stream', 'popular']

    def filter_my_stream(self, qs, name, value):
        return qs.filter(created_by = self.request.user)
        # return qs.filter(collaborator_list__phone_number=self.request.user.username).filter(collaborator_list__can_add_content=True)
        # | Q(created_by=self.request.user) ).distinct().order_by('-view_count')

    def filter_popular(self, qs, name, value):
        return qs.filter(
            Q(type='Public') | Q(collaborator_list__phone_number=self.request.user.username) | \
            Q(created_by=self.request.user)).distinct().order_by('-view_count')


class UsersFilter(django_filters.FilterSet):
    people = django_filters.filters.CharFilter(method='filter_people')

    class Meta:
        model = UserProfile
        fields = ['people']

    def filter_people(self, qs, name, value):
        return qs.filter(Q(full_name__contains=value) | Q(user__username__contains=value))
