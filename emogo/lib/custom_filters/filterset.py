import django_filters
from emogo.apps.stream.models import Stream, Content, LikeDislikeStream, StreamContent, LikeDislikeContent, Folder
from emogo.apps.users.models import UserProfile, UserFollow
from django.db.models import Q
from emogo.apps.collaborator.models import Collaborator
from django.db.models import Prefetch , Count
from emogo.apps.stream.models import StreamUserViewStatus, StarredStream, Folder
from django.core.exceptions import ObjectDoesNotExist
from django.http import Http404
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404
from django.http import Http404
from django.core.exceptions import ObjectDoesNotExist
from itertools import chain


class StreamFilter(django_filters.FilterSet):
    my_stream = django_filters.filters.BooleanFilter(method='filter_my_stream')
    self_created = django_filters.filters.BooleanFilter(method='filter_self_created')
    popular = django_filters.filters.BooleanFilter(method='filter_popular')
    global_search = django_filters.filters.CharFilter(method='filter_global_search')
    name = django_filters.filters.CharFilter(method='filter_name')
    collaborator_qs = Collaborator.actives.all()
    stream_name = django_filters.filters.CharFilter(method='filter_stream_name')
    folder = django_filters.filters.CharFilter(method='filter_by_folder')

    class Meta:
        model = Stream
        fields = ['folder', 'stream_name', 'featured', 'emogo', 'my_stream', 'popular',
                  'self_created']

    def filter_by_folder(self, qs, name, value):
        try:
            folder = Folder.objects.get(id=value)
        except ObjectDoesNotExist:
            raise Http404("Folder does not exist.")
        return qs.filter(folder=folder)
    
    def filter_stream_name(self, qs, name, value):
        return qs.filter(name__icontains=value)

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

        #Get only starred stream in cronological order
        # starred_stream = qs.filter(created_by=self.request.user, stream_starred__id__isnull=False).order_by('-stream_starred__upd')
        # #Get not starred stream in cronological order
        # un_starred_stream = qs.filter(created_by=self.request.user, stream_starred__id__isnull=True).order_by('-upd')
        starred_stream = Stream.objects.select_related(
            "created_by").filter(
            created_by=self.request.user, stream_starred__id__isnull=False).order_by(
            '-stream_starred__upd')
        #Get not starred stream in cronological order
        un_starred_stream = Stream.objects.select_related(
            "created_by").filter(
            created_by=self.request.user, stream_starred__id__isnull=True).order_by('-upd')
        # Merge result
        stream_list = list(chain(starred_stream, un_starred_stream))
        return qs.filter(id__in=[obj.id for obj in stream_list])

    def filter_self_created(self, qs, name, value):
        # Fetch all self created streams
        stream_ids = self.collaborator_qs.filter(created_by_id=self.request.user.id).values_list( 'stream', flat=True)

        # 2. Fetch and return stream Queryset objects without collaborators.
        return qs.exclude(id__in=stream_ids).filter(created_by=self.request.user).order_by('-upd')

    def filter_popular(self, qs, name, value):
        owner_qs = qs.filter(type='Public').order_by('-view_count')
        # Get streams user as collaborator
        stream_ids = self.collaborator_qs.filter(phone_number=self.request.user.username, stream__status='Active').values_list(
            'stream', flat=True)

        # 2. Fetch stream Queryset objects.
        collaborator_permission = qs.filter(id__in=stream_ids)

        # Merge result
        result_list = owner_qs | collaborator_permission
        result_list = list(result_list)
        return result_list

    def filter_global_search(self, qs, name, value):
        # Get streams user as collaborator
        collaborator_permission = self.collaborator_qs.filter(stream__name__icontains=value)
        collaborator_permission = [x.stream.id for x in collaborator_permission if
                                   str(x.phone_number) in str(
                                       self.request.user.username) and x.stream.status == 'Active']
        # Filter collaborator streams and all stream which is contain the value from Stream table
        result_list1 = qs.filter(name__icontains=value, type='Public')
        result_list2 = qs.filter(id__in = collaborator_permission)
        result_list = result_list1 | result_list2
        return result_list


    def filter_name(self, qs, name, request):
        # queryset = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
        #     'created_by__user_data__user').prefetch_related(
        #     Prefetch(
        #         "stream_contents",
        #         queryset=StreamContent.objects.all().select_related('content',
        #                                                             'content__created_by__user_data').prefetch_related(
        #             Prefetch(
        #                 "content__content_like_dislike_status",
        #                 queryset=LikeDislikeContent.objects.filter(status=1),
        #                 to_attr='content_liked_user'
        #             )
        #         ).order_by('order', '-attached_date'),
        #         to_attr="content_list"
        #     ),
        #     Prefetch(
        #         'collaborator_list',
        #         queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
        #         to_attr='stream_collaborator'
        #     ),
        #     Prefetch(
        #         'collaborator_list',
        #         queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
        #         to_attr='stream_collaborator_verified'
        #     ),
        #     Prefetch(
        #         'stream_user_view_status',
        #         queryset=StreamUserViewStatus.objects.all(),
        #         to_attr='total_view_count'
        #     ),
        #     Prefetch(
        #         'stream_like_dislike_status',
        #         queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
        #             Prefetch(
        #                 "user__who_follows",
        #                 queryset=UserFollow.objects.all(),
        #                 to_attr='user_liked_followers'
        #             ),

        #         ),
        #         to_attr='total_like_dislike_data'
        #     ),
        #     Prefetch(
        #         'stream_starred',
        #         queryset=StarredStream.objects.all().select_related('user'),
        #         to_attr='total_starred_stream_data'
        #     ),
        # ).order_by('-stream_view_count')
        obj = qs.filter(created_by=self.request.user).order_by('stream_starred')
        return obj.filter(name__icontains=request)


class CollabsFilter(django_filters.FilterSet):
    stream_name = django_filters.filters.CharFilter(method='filter_stream_name')

    class Meta:
        model = Stream
        fields = ['stream_name']
    
    def filter_stream_name(self, qs, name, value):
        return qs.filter(name__icontains=value)


class UserLikedStreamFilter(django_filters.FilterSet):
    stream_name = django_filters.filters.CharFilter(method='filter_stream_name')

    class Meta:
        model = Stream
        fields = ['stream_name']
    
    def filter_stream_name(self, qs, name, value):
        return qs.filter(name__icontains=value)


class UsersFilter(django_filters.FilterSet):
    people = django_filters.filters.CharFilter(method='filter_people')
    phone = django_filters.filters.CharFilter(method='filter_phone')
    name = django_filters.filters.CharFilter(method='filter_name')

    class Meta:
        model = UserProfile
        fields = ['people', 'phone', 'name']

    def filter_people(self, qs, name, value):
        return qs.filter(Q(full_name__icontains=value) | Q(user__username__contains=value)).exclude(user=self.request.user)

    def filter_phone(self, qs, name, value):
        return qs.filter(user__username__contains=value).exclude(user=self.request.user)

    def filter_name(self, qs, name, value):
        return qs.filter(full_name__icontains=value).exclude(user=self.request.user)


class FollowerFollowingUserFilter(django_filters.FilterSet):
    follower_phone = django_filters.filters.CharFilter(method='filter_follower_phone')
    follower_name = django_filters.filters.CharFilter(method='filter_follower_name')
    following_phone = django_filters.filters.CharFilter(method='filter_following_phone')
    following_name = django_filters.filters.CharFilter(method='filter_following_name')

    class Meta:
        model = UserFollow
        fields = ['follower_phone', 'follower_name', 'following_phone', 'following_name']

    def filter_follower_phone(self, qs, name, value):
        return qs.filter(follower__username__icontains=value)

    def filter_following_phone(self, qs, name, value):
        return qs.filter(following__username__icontains=value)

    def filter_follower_name(self, qs, name, value):
        follower_obj = qs.filter(follower__user_data__display_name__icontains=value)

        if follower_obj:
            return follower_obj
        else:
            return qs.filter(follower__user_data__full_name__icontains=value)


    def filter_following_name(self, qs, name, value):
        following_obj = qs.filter(following__user_data__display_name__icontains=value)

        if following_obj:
            return following_obj
        else:
            return qs.filter(following__user_data__full_name__icontains=value)


class ContentsFilter(django_filters.FilterSet):
    type = django_filters.CharFilter(name='type', lookup_expr='iexact')
    stream = django_filters.filters.CharFilter(method='filter_by_stream')
    content = django_filters.filters.CharFilter(method='filter_by_content')

    class Meta:
        model = Content
        fields = ['type']

    def filter_by_stream(self, qs, name, value):
        try:
            Stream.actives.get(id=value)
        except ObjectDoesNotExist:
            raise Http404("The Emogo does not exist.")
        return qs.filter(content_streams__stream=value)

    def filter_by_content(self, qs, name, value):
        stream = self.request.GET.get("stream")
        try:
            qs.get(id=value, content_streams__stream=stream)
        except ObjectDoesNotExist:
            raise Http404("Content does not exist.")
        return qs.filter(pk=value)


class StreamContentFilter(django_filters.FilterSet):
    stream = django_filters.filters.CharFilter(method='filter_by_stream')
    content = django_filters.filters.CharFilter(method='filter_by_content')

    class Meta:
        model = StreamContent
        fields = []

    def filter_by_stream(self, qs, name, value):
        user = self.request.user
        try:
            stream = Stream.actives.select_related('created_by').prefetch_related(
                Prefetch(
                    'collaborator_list',
                    queryset=Collaborator.actives.all().select_related(
                        'created_by').order_by('-id'),
                    to_attr='stream_collaborator'
                )).get(pk=value)
            if stream.type == "Private" and stream.created_by != user and not any(
                True for collb in stream.stream_collaborator if \
                    user.username.endswith(collb.phone_number[-10:])):
                raise ObjectDoesNotExist
        except ObjectDoesNotExist:
            raise Http404("The Emogo does not exist.")
        return qs.filter(stream_id=value)

    def filter_by_content(self, qs, name, value):
        stream = self.request.GET.get("stream")
        stream_contents = qs.filter(content_id=value, stream_id=stream)
        if stream_contents:
            return stream_contents
        raise Http404("Content does not exist.")


class UserStreamFilter(django_filters.FilterSet):
    stream_name = django_filters.filters.CharFilter(method='filter_stream_name')
    created_by = django_filters.filters.NumberFilter(method='filter_created_by')
    emogo_stream = django_filters.filters.NumberFilter(method='filter_emogo_stream')
    collab_stream = django_filters.filters.NumberFilter(method='filter_collab_stream')
    private_stream = django_filters.filters.NumberFilter(method='filter_private_stream')
    public_stream = django_filters.filters.NumberFilter(method='filter_public_stream')
    following_stream = django_filters.filters.BooleanFilter(method='filter_following_stream')
    follower_stream = django_filters.filters.BooleanFilter(method='filter_follower_stream')

    class Meta:
        model = Stream
        fields = ['stream_name', 'created_by', 'emogo_stream', 'collab_stream',
                  'private_stream', 'public_stream', 'following_stream', 'follower_stream']

    def filter_stream_name(self, qs, name, value):
        return qs.filter(name__icontains=value)

    def filter_created_by(self, qs, name, value):
        get_object_or_404(UserFollow, follower=self.request.user, following_id=value)
        # 1. Get user as collaborator in streams created by requested user.
        stream_ids = Collaborator.actives.filter(phone_number=self.request.user.username, stream__status='Active',
                                                 stream__type='Private', created_by__user_data__id=value).values_list(
            'stream', flat=True)

        # 2. Fetch stream Queryset objects.
        stream_as_collabs = qs.filter(id__in=stream_ids)

        # 3. Get main stream created by requested user and stream type is Public.
        main_qs = qs.filter(created_by__user_data__id=value, type='Public').order_by('-upd')
        qs = main_qs | stream_as_collabs
        return qs

    def filter_following_stream(self, qs, name, value):
        following_ids = UserFollow.objects.filter(follower=self.request.user).values_list('following_id', flat=True)
        # 1. Get user as collaborator in streams created by following's
        stream_ids = Collaborator.actives.filter(phone_number=self.request.user.username, stream__status='Active',
                                                 stream__type='Private', created_by_id__in=following_ids).values_list(
            'stream', flat=True)

        # 2. Fetch stream Queryset objects.
        stream_as_collabs = qs.filter(id__in=stream_ids)

        # 3. Get main stream created by requested user and stream type is Public.
        main_qs = qs.filter(created_by__in=following_ids, type='Public')
        qs = main_qs | stream_as_collabs
        qs = list(qs.order_by('-upd'))
        # stream_ids_list = list(following_ids)
        # qs.sort(key=lambda t: stream_ids_list.index(t.created_by_id))
        return qs

    def filter_follower_stream(self, qs, name, value):
        follower_ids = UserFollow.objects.filter(following=self.request.user).values_list('follower_id', flat=True).order_by('-follow_time')
        # 1. Get user as collaborator in streams created by follower's.
        stream_ids = Collaborator.actives.filter(phone_number=self.request.user.username, stream__status='Active',
                                                 stream__type='Private', created_by_id__in=follower_ids).values_list(
            'stream', flat=True)

        # 2. Fetch stream Queryset objects.
        stream_as_collabs = qs.filter(id__in=stream_ids)

        # 3. Get main stream created by requested user and stream type is Public.
        main_qs = qs.filter(created_by__in=follower_ids, type='Public').order_by('-upd')
        qs = main_qs | stream_as_collabs
        return qs

    def filter_emogo_stream(self, qs, name, value):
        user = get_object_or_404(User, id=value)
        # 1. Get user as collaborator in streams created by requested user.
        stream_ids = Collaborator.actives.filter(stream__status='Active', created_by_id = user.id).values_list('stream', flat=True)

        # 2. Fetch and return stream Queryset objects without collaborators.
        return  qs.exclude(id__in=stream_ids).filter(created_by_id= user.id, type='Public').order_by('-upd')

    def filter_collab_stream(self, qs, name, value):
        user = get_object_or_404(User, id=value)
        stream_ids = Collaborator.actives.filter(
            (
                (Q(phone_number__endswith=str(self.request.user.username)[-10:]) & Q(created_by_id = user.id)) |
                (Q(phone_number__endswith=str(user.username)[-10:]) & Q(created_by_id = self.request.user.id))
            ) & Q(stream__status='Active')).values_list('stream', flat=True)
        qs = qs.filter(id__in=stream_ids)
        return qs

    def filter_private_stream(self, qs, name, value):
        qs = qs.filter(created_by__user_data__id=value, type='Private').order_by('-upd')
        return qs

    def filter_public_stream(self, qs, name, value):
        qs = qs.filter(created_by__user_data__id=value, type='Public').order_by('-upd')
        return qs

    def get_prefetch_records(self, qs):
        return qs.select_related('created_by__user_data').prefetch_related(
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
        ).order_by('-upd')


class StarredStreamFilter(django_filters.FilterSet):
    stream_name = django_filters.filters.CharFilter(method='filter_stream_name')

    class Meta:
        model = StarredStream
        fields = ['stream_name']

    def filter_stream_name(self, qs, name, value):
        return qs.filter(stream__name__icontains=value)


class NewEmogosFilter(django_filters.FilterSet):
    emogo_name = django_filters.filters.CharFilter(method='filter_emogo_name')

    class Meta:
        model = Stream
        fields = ['emogo_name']

    def filter_emogo_name(self, qs, name, value):
        return qs.filter(name__icontains=value)


class OpenStreamContentFilter(django_filters.FilterSet):
    stream = django_filters.filters.CharFilter(method='filter_by_stream')
    content = django_filters.filters.CharFilter(method='filter_by_content')

    class Meta:
        model = StreamContent
        fields = []

    def filter_by_stream(self, qs, name, value):
        stream_contents = qs.filter(stream_id=value)
        if stream_contents:
            return stream_contents
        raise Http404("The Emogo does not exist.")

    def filter_by_content(self, qs, name, value):
        stream_contents = qs.filter(content_id=value)
        if stream_contents:
            return stream_contents
        raise Http404("Content does not exist.")
