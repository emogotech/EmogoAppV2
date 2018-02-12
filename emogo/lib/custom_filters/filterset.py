import django_filters
from emogo.apps.stream.models import Stream, Content
from emogo.apps.users.models import UserProfile
from django.db.models import Q
from itertools import chain
from emogo.apps.collaborator.models import Collaborator


class StreamFilter(django_filters.FilterSet):
    my_stream = django_filters.filters.BooleanFilter(method='filter_my_stream')
    self_created = django_filters.filters.BooleanFilter(method='filter_self_created')
    popular = django_filters.filters.BooleanFilter(method='filter_popular')
    global_search = django_filters.filters.CharFilter(method='filter_global_search')
    collaborator_qs = Collaborator.actives.all()

    class Meta:
        model = Stream
        fields = ['featured', 'emogo', 'my_stream', 'popular', 'self_created']

    def filter_my_stream(self, qs, name, value):
        # Get self created streams
        # owner_qs = qs.filter(created_by=self.request.user)
        #
        # # Get streams user as collaborator and has add content permission
        # collaborator_permission = self.collaborator_qs
        # collaborator_permission = [x.stream for x in collaborator_permission if
        #                            str(x.phone_number) in str(
        #                                self.request.user.username) and x.stream.status == 'Active']
        # # Merge result
        # result_list = list(chain(owner_qs, collaborator_permission))
        # return result_list
        return qs.filter(created_by=self.request.user).order_by('-upd')

    def filter_self_created(self, qs, name, value):
        # Get self created streams
        return qs.filter(created_by=self.request.user).order_by('-upd')

    def filter_popular(self, qs, name, value):
        owner_qs = qs.filter(type='Public').order_by('-view_count')
        # Get streams user as collaborator
        collaborator_permission = self.collaborator_qs
        collaborator_permission = [x.stream for x in collaborator_permission if
                                   str(x.phone_number) in str(
                                       self.request.user.username) and x.stream.status == 'Active']
        # Merge result
        result_list = list(chain(owner_qs, collaborator_permission))
        return result_list

    def filter_global_search(self, qs, name, value):
        public_stream = qs.filter(name__icontains=value, type='Public')
        # Get streams user as collaborator
        collaborator_permission = self.collaborator_qs.filter(stream__name__icontains=value).exclude(stream__type='Public')
        collaborator_permission = [x.stream for x in collaborator_permission if
                                   str(x.phone_number) in str(
                                       self.request.user.username) and x.stream.status == 'Active']
        # Merge result
        result_list = list(chain(public_stream, collaborator_permission))
        return result_list


class UsersFilter(django_filters.FilterSet):
    people = django_filters.filters.CharFilter(method='filter_people')

    class Meta:
        model = UserProfile
        fields = ['people']

    def filter_people(self, qs, name, value):
        return qs.filter(Q(full_name__icontains=value) | Q(user__username__contains=value)).exclude(user=self.request.user)


class ContentsFilter(django_filters.FilterSet):
    type = django_filters.CharFilter(name='type', lookup_expr='iexact')

    class Meta:
        model = Content
        fields = ['type']

