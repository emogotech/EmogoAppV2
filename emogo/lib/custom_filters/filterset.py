import django_filters
from emogo.apps.stream.models import Stream, Content
from emogo.apps.users.models import UserProfile
from django.db.models import Q
from itertools import chain


class StreamFilter(django_filters.FilterSet):
    my_stream = django_filters.filters.BooleanFilter(method='filter_my_stream')
    popular = django_filters.filters.BooleanFilter(method='filter_popular')
    global_search = django_filters.filters.CharFilter(method='filter_global_search')

    class Meta:
        model = Stream
        fields = ['featured', 'emogo', 'my_stream', 'popular']

    def filter_my_stream(self, qs, name, value):
        # Get self created streams
        owner_qs = qs.filter(created_by=self.request.user).distinct()

        # Get streams user as collaborator and has add content permission
        collaborator_permission = qs.filter(collaborator_list__phone_number=self.request.user.username, collaborator_list__can_add_content=True).distinct()

        # merge result
        result_list = list(chain(owner_qs,collaborator_permission))
        return result_list

    def filter_popular(self, qs, name, value):
        return qs.filter(
            Q(type='Public') | Q(collaborator_list__phone_number=self.request.user.username) |\
            Q(created_by=self.request.user)).distinct().order_by('-view_count')

    def filter_global_search(self, qs, name, value):
        # return qs.filter(Q(name__contains=value) | Q(content__name__contains=value)).distinct().order_by('-view_count')
        return qs.filter(name__icontains=value, type='Public').order_by('-view_count')


class UsersFilter(django_filters.FilterSet):
    people = django_filters.filters.CharFilter(method='filter_people')

    class Meta:
        model = UserProfile
        fields = ['people']

    def filter_people(self, qs, name, value):
        return qs.filter(Q(full_name__contains=value) | Q(user__username__contains=value))


class ContentsFilter(django_filters.FilterSet):
    type = django_filters.CharFilter(name='type', lookup_expr='iexact')

    class Meta:
        model = Content
        fields = ['type']

