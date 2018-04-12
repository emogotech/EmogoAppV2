import django_filters
from emogo.apps.stream.models import Stream, Content
from emogo.apps.users.models import UserProfile, UserFollow
from django.db.models import Q
from itertools import chain
from emogo.apps.collaborator.models import Collaborator
from django.db.models import Prefetch
from emogo.apps.stream.models import StreamUserViewStatus
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404


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


class UserStreamFilter(django_filters.FilterSet):
    created_by = django_filters.filters.NumberFilter(method='filter_created_by')
    emogo_stream = django_filters.filters.NumberFilter(method='filter_emogo_stream')
    collab_stream = django_filters.filters.NumberFilter(method='filter_collab_stream')
    private_stream = django_filters.filters.NumberFilter(method='filter_private_stream')
    public_stream = django_filters.filters.NumberFilter(method='filter_public_stream')

    class Meta:
        model = Stream
        fields = ['created_by']

    def filter_created_by(self, qs, name, value):
        get_object_or_404(UserFollow, follower=self.request.user, following_id=value)
        #1. Get user as collaborator in streams created by requested user.
        stream_ids = Collaborator.actives.filter(phone_number=self.request.user.username, stream__status='Active', stream__type='Private', created_by__user_data__id=value).values_list('stream', flat=True)

        #2. Fetch stream Queryset objects.
        stream_as_collabs = qs.filter(id__in=stream_ids)

        #3. Get main stream created by requested user and stream type is Public.
        main_qs = qs.filter(created_by__user_data__id=value, type='Public').order_by('-upd')
        qs = main_qs | stream_as_collabs
        qs = self.get_prefetch_records(qs)
        return qs

    def filter_emogo_stream(self, qs, name, value):
        qs = qs.filter(created_by__user_data__id=value, type='Public').order_by('-upd')
        qs = self.get_prefetch_records(qs)
        return qs

    def filter_collab_stream(self, qs, name, value):
        stream_ids = Collaborator.actives.filter(phone_number=get_object_or_404(User, user_data__id=value),
                                         stream__status='Active',
                                         created_by=self.request.user).values_list('stream', flat=True)
        qs = qs.filter(id__in=stream_ids)
        qs = self.get_prefetch_records(qs)
        return qs

    def filter_private_stream(self, qs, name, value):
        qs = qs.filter(created_by__user_data__id=value, type='Private').order_by('-upd')
        qs = self.get_prefetch_records(qs)
        return qs

    def filter_public_stream(self, qs, name, value):
        qs = qs.filter(created_by__user_data__id=value, type='Public').order_by('-upd')
        qs = self.get_prefetch_records(qs)
        return qs

    def get_prefetch_records(self, qs):
        return qs.select_related('created_by__user_data').prefetch_related(
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
        )