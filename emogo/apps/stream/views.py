# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.http import HttpResponse, HttpResponseRedirect, Http404
from rest_framework import status
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from emogo.lib.helpers.utils import custom_render_response
from models import Stream, Content, ExtremistReport, StreamContent, LikeDislikeStream, StreamUserViewStatus, LikeDislikeContent, StarredStream
from serializers import StreamSerializer, ViewStreamSerializer, ContentSerializer, ViewContentSerializer, \
    ContentBulkDeleteSerializer, MoveContentToStreamSerializer, ExtremistReportSerializer, DeleteStreamContentSerializer,\
    ReorderStreamContentSerializer, ReorderContentSerializer, StreamLikeDislikeSerializer, StarredSerializer, CopyContentSerializer, \
    ContentLikeDislikeSerializer, StreamUserViewStatusSerializer, AddBookmarkSerializer, BookmarkNewEmogosSerializer, RecentUpdatesSerializer
from emogo.lib.custom_filters.filterset import StreamFilter, ContentsFilter, StarredStreamFilter, NewEmogosFilter
from rest_framework.views import APIView
from django.core.urlresolvers import resolve
from django.shortcuts import get_object_or_404
import itertools
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.users.models import UserFollow
from emogo.apps.notification.models import Notification
from emogo.apps.notification.views import NotificationAPI
from django.db.models import Prefetch, Count
from django.db.models import QuerySet
from django.contrib.auth.models import User
import datetime
from rest_framework.authtoken.models import Token
from rest_framework import filters


class StreamAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = StreamSerializer
    queryset = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related('created_by__user_data__user').prefetch_related(
            Prefetch(
                "stream_contents",
                queryset=StreamContent.objects.all().select_related('content', 'content__created_by__user_data').prefetch_related(
                    Prefetch(
                        "content__content_like_dislike_status",
                        queryset=LikeDislikeContent.objects.filter(status=1),
                        to_attr='content_liked_user'
                    )
                ).order_by('order', '-attached_date'),
                to_attr="content_list"
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
                to_attr='stream_collaborator'
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
                to_attr='stream_collaborator_verified'
            ),
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
            Prefetch(
                'stream_like_dislike_status',
                queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
                        Prefetch(
                            "user__who_follows",                            
                            queryset=UserFollow.objects.all(),
                            to_attr='user_liked_followers'                                   
                        ),

                ),
                to_attr='total_like_dislike_data'
            ),
        ).order_by('-stream_view_count')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'
    filter_class = StreamFilter

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, version, *args, **kwargs):
        if kwargs.get('pk') is not None:
            return self.retrieve(request, version, *args, **kwargs)
        else:
            return self.list(request, version, *args, **kwargs)

    def retrieve(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """

        instance = self.get_object()
        self.serializer_class = ViewStreamSerializer
        current_url = resolve(request.path_info).url_name
        # This condition response only stream collaborators.
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')
        if current_url == 'stream_collaborator':
            user_data = User.objects.filter(username__in=[x.phone_number for x in instance.stream_collaborator]).values('username','user_data__user_image')
            self.request.data.update({'collab_user_image': user_data})
            serializer = self.get_serializer(instance, fields=fields, context=self.request)
        # Return all data
        else:
            serializer = self.get_serializer(instance, fields=fields, context=self.request)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        self.serializer_class = ViewStreamSerializer
        queryset = self.filter_queryset(self.queryset)
        #  Customized field list
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width',
                  'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission',
                  'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators',
                  'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked',
                  'user_liked', 'collab_images', 'total_stream_collaborators']
        if version == 'v3':
            fields.remove('collaborators')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)

    def create(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data, context=self.get_serializer_context())
        serializer.is_valid(raise_exception=True)
        stream = serializer.create(serializer.validated_data)
        # To return created stream data
        self.serializer_class = ViewStreamSerializer
        stream = self.queryset.filter(id=stream.id).prefetch_related('stream_contents', 'collaborator_list')[0]
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators']
        if version == 'v3':
            fields.remove('collaborators')
        serializer = self.get_serializer(stream, context=self.request, fields=fields)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def update(self, request, version, *args, **kwargs):
        """
        :param request: ALL request data
        :param args: request param as list
        :param kwargs: request param as dict
        :return: Update stream instance
        """

        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        # import pdb;
        # pdb.set_trace()
        self.perform_update(serializer)
        instance = self.get_object()
        self.serializer_class = ViewStreamSerializer
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators']
        if version == 'v3':
            fields.remove('collaborators')
        serializer = self.get_serializer(instance, context=self.request, fields=fields)
        if getattr(instance, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def destroy(self, request, version, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Soft Delete Stream and it's attribute
        """
        instance = self.get_object()
        #update notification when user delete stream
        noti = Notification.objects.filter(notification_type = 'collaborator_confirmation' , stream = instance, from_user = instance.created_by)
        if noti.__len__() > 0 :
            noti.update(notification_type = 'deleted_stream')
        # Perform delete operation
        self.perform_destroy(instance)
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


# Todo the DeleteStreamContentAPI is not used but it was keep because it is using in last build.
class DeleteStreamContentAPI(DestroyAPIView):

    serializer_class = DeleteStreamContentSerializer
    queryset = Stream.actives.all().order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def destroy(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: Contents as list data
        :param kwargs: dict param
        :return: Delete Stream Content.
        """

        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.delete_content()
        return custom_render_response(status_code=status.HTTP_200_OK, data=None)


class DeleteStreamContentInBulkAPI(APIView):

    serializer_class = DeleteStreamContentSerializer
    queryset = Stream.actives.all().order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_object(self):
        return get_object_or_404(Stream, pk=self.kwargs.get('pk'))

    def post(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: Contents as list data
        :param kwargs: dict param
        :return: Delete Stream Content.
        """

        instance = self.get_object()
        serializer = self.serializer_class(instance, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.delete_content()
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


class CopyContentAPI(APIView):

    serializer_class = CopyContentSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_object(self):
        return get_object_or_404(Content.actives, pk=self.request.data.get('content_id'))

    def post(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: None
        :param kwargs: Content_id
        :return: Copy content with new owner
        """

        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        instance = self.get_object()
        serializer = self.serializer_class(instance, data=request.data, context=self.request)
        serializer.copy_content()
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=None)


class ContentAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ContentSerializer
    queryset = Content.actives.all().select_related('created_by__user_data__user').prefetch_related(
        Prefetch(
            "content_like_dislike_status",
            queryset=LikeDislikeContent.objects.filter(status=1),
            to_attr='content_liked_user'
        )
    ).order_by('order', '-crd')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_class = ContentsFilter

    def filter_queryset(self, queryset):
        """
        Given a queryset, filter it with whichever filter backend is in use.

        You are unlikely to want to override this method, although you may need
        to call it either from a list view, or from a custom `get_object`
        method if you want to apply the configured filtering backend to the
        default queryset.
        """
        queryset = queryset.filter(created_by=self.request.user)
        for backend in list(self.filter_backends):
            queryset = backend().filter_queryset(self.request, queryset, self)
        return queryset

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, version, *args, **kwargs):
        if kwargs.get('pk') is not None:
            return self.retrieve(request, version, *args, **kwargs)
        else:
            return self.list(request, version, *args, **kwargs)

    def get_object(self):
        qs = self.get_queryset().filter(pk=self.kwargs.get('pk'))
        if qs.exists():
            return qs[0]
        else:
            return Http404

    def retrieve(self, request, version, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get Stream detail API.
        """
        #  Developer overwrite the self.get_object() method because any one can see content Detail
        instance = self.get_object()
        self.serializer_class = ViewContentSerializer
        serializer = self.get_serializer(instance)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = (
        'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width', 'order',
        'color', 'user_image', 'full_name', 'order', 'liked')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)

    def create(self, request, version, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, many=True)
        serializer.is_valid(raise_exception=True)
        instances = serializer.create(serializer.validated_data)
        serializer = ViewContentSerializer(instances, many=True, fields=(
        'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width', 'order',
        'color', 'user_image', 'full_name', 'order'))
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def update(self, request, version, *args, **kwargs):
        """
        :param request: ALL request data
        :param args: request param as list
        :param kwargs: request param as dict
        :return: Update stream instance
        """
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        if getattr(instance, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}
        self.serializer_class = ViewContentSerializer
        #  Customized field list
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width',
            'order',
            'color', 'user_image', 'full_name', 'order', 'liked')
        serializer = self.get_serializer(instance, fields=fields)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def destroy(self, request, version, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Soft Delete Content and it's attribute
        """
        self.serializer_class = ContentBulkDeleteSerializer
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        queryset = Content.actives.all().order_by('-upd')
        queryset.filter(id__in=self.request.data['content_list']).update(status='Inactive')
        # Delete stream and content relation.
        StreamContent.objects.filter(content__in=self.request.data.get('content_list')).delete()
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


class GetTopContentAPI(ContentAPI):
    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width',
            'order', 'color', 'full_name', 'user_image', 'liked')
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        picture_type = self.get_serializer(queryset.filter(type='Picture')[0:10], many=True, fields=fields)
        video_type = self.get_serializer(queryset.filter(type='Video')[0:10], many=True, fields=fields)
        link_type = self.get_serializer(queryset.filter(type='Link')[0:10], many=True, fields=fields)
        giphy_type = self.get_serializer(queryset.filter(type='Giphy')[0:10], many=True, fields=fields)
        notes_type = self.get_serializer(queryset.filter(type='Note')[0:10], many=True, fields=fields)
        all = self.get_serializer(queryset[0:20], many=True, fields=fields)
        data = {'picture': picture_type.data, 'video': video_type.data, 'link': link_type.data,
                'giphy': giphy_type.data, 'note': notes_type.data, 'all': all.data}
        return custom_render_response(data=data, status_code=status.HTTP_200_OK)


class GetTopTwentyContentAPI(ContentAPI):
    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width',
            'order', 'color', 'full_name', 'user_image', 'liked')
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        final_qs = itertools.chain(queryset.filter(type='Link')[0:5], queryset.filter(type='Picture')[0:5],
                                   queryset.filter(type='Video')[0:5], queryset.filter(type='Giphy')[0:5], queryset.filter(type='Note')[0:5])
        serializer = self.get_serializer(final_qs, many=True, fields=fields)
        return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)


class LinkTypeContentAPI(ListAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ContentSerializer
    queryset = Content.actives.all().select_related('created_by__user_data__user').prefetch_related(
        Prefetch(
            "content_like_dislike_status",
            queryset=LikeDislikeContent.objects.filter(status=1),
            to_attr='content_liked_user'
        )
    ).order_by('order', '-crd')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def filter_queryset(self, queryset):
        """
        Given a queryset, filter it with whichever filter backend is in use.

        You are unlikely to want to override this method, although you may need
        to call it either from a list view, or from a custom `get_object`
        method if you want to apply the configured filtering backend to the
        default queryset.
        """
        queryset = queryset.filter(created_by=self.request.user, type='Link')
        for backend in list(self.filter_backends):
            queryset = backend().filter_queryset(self.request, queryset, self)
        return queryset

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ('id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image','height', 'width',
                  'full_name', 'user_image', 'liked')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class DeleteContentInBulk(APIView):
    """
    View to list all users in the system.

    * Requires token authentication.
    * Only admin users are able to access this view.
    """
    serializer_class = ContentBulkDeleteSerializer
    queryset = Content.actives.all().order_by('-upd')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request, version):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        self.queryset.filter(id__in=self.request.data['content_list']).update(status='Inactive')
        # Delete stream and content relation.
        StreamContent.objects.filter(content__in=self.request.data.get('content_list')).delete()
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


class RecentUpdatesAPI(ListAPIView):
    """"
    View to list all the recent updates of the logged in user.
    """
    queryset = StreamContent.objects.all()
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(queryset, many=True, fields=('name', 'image', 'status','id'))
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(queryset, many=True, fields=('name', 'image', 'status','id'))
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def get_queryset(self):
        """
        Get the list of items for this view.
        This must be an iterable, and may be a queryset.
        Defaults to using `self.queryset`.

        This method should always be used rather than accessing `self.queryset`
        directly, as `self.queryset` gets evaluated only once, and those results
        are cached for all subsequent requests.

        You may want to override this if you need to provide different
        query sets depending on the incoming request.

        (Eg. return a list of items that is specific to the user)
        """
        assert self.queryset is not None, (
                "'%s' should either include a `queryset` attribute, "
                "or override the `get_queryset()` method."
                % self.__class__.__name__
        )
        queryset = self.queryset
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        current_user_streams = Stream.objects.filter(created_by=self.request.user, status='Active', type="Public", crd__gt=week_ago)
        # list all the objects of active streams created by logged in user.
        following = UserFollow.objects.filter(follower=self.request.user).values_list('following', flat=True)
        # list all the objects of users whom logged in user is following.
        all_following_public_streams = Stream.objects.filter(created_by_id__in=following, status="Active", type="Public", crd__gt=week_ago)
        # list all the objects of streams created by users followed by current user
        user_as_collaborator_streams = Collaborator.objects.filter(phone_number=self.request.user.username).values_list('stream_id', flat=True)
        # list all the objects of streams where the current user is as collaborator.
        user_as_collaborator_active_streams = Stream.objects.filter(id__in=user_as_collaborator_streams, status="Active", type="Public", crd__gt=week_ago)
        # list all the objects of active streams where the current user is as collaborator.
        # import pdb;pdb.set_trace()
        all_streams = current_user_streams | all_following_public_streams | user_as_collaborator_active_streams


        # content_ids = StreamContent.objects.filter(stream__in=all_streams).annotate(total_view_count=Count('content_id')).values(
                            # 'stream_id', 'content_id', 'user_id')
        content_ids = StreamContent.objects.filter(stream__in=all_streams).annotate(total_view_count=Count('content_id'))

        if isinstance(queryset, QuerySet):
            # Ensure queryset is re-evaluated on each request.
            queryset = current_user_streams | all_following_public_streams | user_as_collaborator_active_streams
            # list all the objects of active streams which are related to current user in any way.
        return queryset


class MoveContentToStream(APIView):
    """
    View to list all users in the system.

    * Requires token authentication.
    * Only admin users are able to access this view.
    """
    serializer_class = MoveContentToStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

    def post(self, request, version):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.get_serializer_context())
        if serializer.is_valid():
            serializer.save()
            return custom_render_response(status_code=status.HTTP_200_OK, data={})
        else:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST, data=serializer.errors)


class ReorderStreamContent(APIView):
    """
    Reorder stream content API

    * Requires token authentication.
    * Only stream owner can access REORDER STREAM CONTENT.
    """
    serializer_class = ReorderStreamContentSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request, version):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        if serializer.is_valid():
            serializer.reorder_content()
            return custom_render_response(status_code=status.HTTP_200_OK, data={})
        else:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST, data=serializer.errors)


class ReorderContent(APIView):
    """
    Reorder stream content API

    * Requires token authentication.
    * Only stream owner can access REORDER STREAM CONTENT.
    """
    serializer_class = ReorderContentSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request, version):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        if serializer.is_valid():
            serializer.reorder_content()
            return custom_render_response(status_code=status.HTTP_200_OK, data={})
        else:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST, data=serializer.errors)


class ExtremistReportAPI(CreateAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ExtremistReportSerializer
    queryset = ExtremistReport.objects.all()
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def create(self, request, version, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=self.request.data)


class StreamLikeDislikeAPI(CreateAPIView, RetrieveAPIView):
    """
    Like Dislike CRUD API
    """
    serializer_class = StreamLikeDislikeSerializer
    queryset = LikeDislikeStream.objects.filter().select_related('stream').order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'

    def get_serializer_context(self):
        followers = UserFollow.objects.filter(follower=self.request.user).values_list('following_id', flat=True)
        return {'request': self.request, 'followers':followers}
    
    def get(self, request, version, *args, **kwargs):
        if kwargs.get('stream_id') is not None:
            return self.retrieve(request, *args, **kwargs)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data, context=self.get_serializer_context())
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer)
        stream = Stream.objects.get(id =  serializer.data.get('stream'))
        if (serializer.data.get('status') == 1) and (self.request.user !=  stream.created_by) and kwargs.get('version'):
            noti = Notification.objects.filter(notification_type = 'liked_emogo' , stream = stream, from_user = self.request.user, to_user = stream.created_by)
            if noti.__len__() > 0 :
                noti[0].save()
                NotificationAPI().initialize_notification(noti[0])
            else:
                NotificationAPI().send_notification(self.request.user, stream.created_by, 'liked_emogo', stream)
        # To return created stream data
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)
    
    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        """
        # Customized field list
        fields = ( 'total_liked', 'user_liked')
        queryset = Stream.objects.filter(id = kwargs.get('stream_id'))
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.get_serializer_context())
        return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)


class StreamLikeAPI(RetrieveAPIView):
    """
    Like Dislike CRUD API
    """
    serializer_class = StreamLikeDislikeSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_serializer_context(self):
        followers = UserFollow.objects.filter(follower=self.request.user).values_list('following_id', flat=True)
        return {'request': self.request, 'followers':followers}
    
    def get(self, request, *args, **kwargs):
        if kwargs.get('stream_id') is not None:
            return self.retrieve(request, *args, **kwargs)

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        """
        # Customized field list
        fields = ( 'total_liked', 'user_liked')
        queryset = Stream.objects.filter(id =  kwargs.get('stream_id'))
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.get_serializer_context())
        return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)

class ContentLikeDislikeAPI(CreateAPIView):
    """
    Like dislike CRUD API
    """
    serializer_class = ContentLikeDislikeSerializer
    queryset = LikeDislikeContent.objects.select_related('content').order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """

        serializer = self.get_serializer(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer)
        content = Content.objects.get(id =  serializer.data.get('content'))
        if (serializer.data.get('status') == 1) and (self.request.user !=  content.created_by) and kwargs.get('version') :
            noti = Notification.objects.filter(notification_type = 'liked_content' , stream = content.content_streams.all()[0].stream, from_user = self.request.user, to_user = content.created_by, content = content)
            if noti.__len__() > 0 :
                noti[0].save()
                NotificationAPI().initialize_notification(noti[0])
            else:
                NotificationAPI().send_notification(self.request.user, content.created_by, 'liked_content', content.content_streams.all()[0].stream, content)
        # To return created stream data
        # self.serializer_class = ViewStreamSerializer
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)


def get_stream_qs_objects(instances=None):
    """
    :param instances:
    :return: This functio will return all stream collaborators, contents and stream view status in single query
    """
    qs = QuerySet()
    # if type Queryset or list of Objects
    if isinstance(instances, QuerySet) or isinstance(instances, list):
        if isinstance(instances, list) :
            instances = Stream.actives.filter(id__in=[_.id for _ in instances])
        qs = instances.select_related('created_by__user_data__user')

    # if type Stream object
    elif isinstance(instances, Stream):
        qs = Stream.actives.filter(id=getattr(instances, 'id'))
    qs = qs.prefetch_related(
            Prefetch(
                "stream_contents",
                queryset=StreamContent.objects.all().select_related('content').order_by('order'),
                to_attr="content_list"
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
                to_attr='stream_collaborator'
            ),
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
            Prefetch(
                'stream_like_dislike_status',
                queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data'),
                to_attr='total_like_dislike_data'
            ),

        )
    if isinstance(instances, Stream):
        if qs.exists():
            return qs[0]
    return qs


class IncreaseStreamViewCount(CreateAPIView):
    """
    Like Dislike CRUD API
    """
    serializer_class = StreamUserViewStatusSerializer
    queryset = StreamUserViewStatus.objects.all().select_related('stream')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer)
        # To return created stream data
        # self.serializer_class = ViewStreamSerializer
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)


class ContentInBulkAPI(ContentAPI):
    """
    Get Contents in bulk
    """
    def list(self, request, version, *args, **kwargs):
        """
        :param ids: list of content ids
        :return: All content details.
        """
        self.serializer_class = ViewContentSerializer
        ids = eval(request.query_params['ids']) if request.query_params.get('ids') else ''
        queryset = self.get_queryset().filter(id__in=ids)
        #  Customized field list
        fields = (
        'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width', 'order',
        'color', 'user_image', 'full_name', 'order', 'liked')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class ContentShareExtensionAPI(CreateAPIView):
    """
    Save content from share extension API
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Send notification API.
        """
        # content_ids = [ x.id for x in self.request.data.get('contents')]
        NotificationAPI().send_notification(self.request.user, self.request.user, 'self', None, None, self.request.data.get('contents').__len__(), str(self.request.data.get('contents')))
        return custom_render_response(status_code=status.HTTP_200_OK)

        # following = UserFollow.objects.filter(follower=self.request.user.id).values_list('following', flat=True)
        # view_status = StreamUserViewStatus.objects.filter(user=self.request.user.id).values_list('stream', flat=True)
        # creators_list = list(following)
        # # creators_list = [1,2,3,4,5]
        # user_current = self.request.user.id
        # creators_list.append(user_current)
        # view_status_list = list(view_status)
        # # view_status_list = [3,4]
        # import pdb; pdb.set_trace()
        # creators_list = list(set(creators_list) & set(view_status_list))
        # if isinstance(queryset, QuerySet):
        #     # Ensure queryset is re-evaluated on each request.
        #     queryset = queryset.filter(created_by_id__in=creators_list, status ='Active')
        #
        # return queryset


class AddBookmarkAPI(CreateAPIView):
    """
    Add Bookmark CRUD API
    """
    serializer_class = AddBookmarkSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        This function bookmark stream
        """
        serializer = self.get_serializer(data=request.data, context=self.get_serializer_context())
        serializer.is_valid(raise_exception=True)
        serializer.create(serializer)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data={})


class BookmarkNewEmogosAPI(ListAPIView):
    """"
    View to list all the starred and new Emogos in home page.
    """
    queryset = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
        'created_by__user_data__user').prefetch_related(
        Prefetch(
            "stream_contents",
            queryset=StreamContent.objects.all().select_related('content','content__created_by__user_data').prefetch_related(
                    Prefetch(
                        "content__content_like_dislike_status",
                        queryset=LikeDislikeContent.objects.filter(status=1),
                        to_attr='content_liked_user'
                    )
                ).order_by('order', '-attached_date'),
            to_attr="content_list"
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator'
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator_verified'
        ),
        Prefetch(
                'stream_like_dislike_status',
                queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
                        Prefetch(
                            "user__who_follows",
                            queryset=UserFollow.objects.all(),
                            to_attr='user_liked_followers'
                        ),

                ),
                to_attr='total_like_dislike_data'
            ),
        Prefetch(
            'stream_user_view_status',
            queryset=StreamUserViewStatus.objects.all(),
            to_attr='total_view_count'
        )
    ).order_by('-id')
    queryset_bookmark = StarredStream.objects.filter().select_related('stream')
    serializer_class = BookmarkNewEmogosSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        fields = (
        'id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update',
        'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes',
        'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo',
        'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')
        user_bookmarks = self.queryset_bookmark.filter(user=self.request.user, stream__status='Active')[:10]
        user_bookmarks_stream = self.queryset.filter(id__in = [x.stream.id for x in user_bookmarks.select_related('stream')])
        user_bookmarks_serializer = ViewStreamSerializer(user_bookmarks_stream[0:10], fields=fields, many=True, context=self.get_serializer_context())

        serializer = ViewStreamSerializer(queryset[0:10], fields=fields, many=True, context=self.get_serializer_context())
        return_dictionary={'new_emogos': serializer.data, "bookmarks": user_bookmarks_serializer.data}
        return custom_render_response(status_code=status.HTTP_200_OK, data=return_dictionary)

    def get_queryset(self):
        """
        Get the list of items for this view.
        This must be an iterable, and may be a queryset.
        Defaults to using `self.queryset`.

        This method should always be used rather than accessing `self.queryset`
        directly, as `self.queryset` gets evaluated only once, and those results
        are cached for all subsequent requests.

        You may want to override this if you need to provide different
        querysets depending on the incoming request.

        (Eg. return a list of items that is specific to the user)
        """
        assert self.queryset is not None, (
                "'%s' should either include a `queryset` attribute, "
                "or override the `get_queryset()` method."
                % self.__class__.__name__
        )

        queryset = self.queryset
        queryset_bookmark = self.queryset_bookmark
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        current_user_streams = queryset.filter(created_by=self.request.user, status='Active', crd__gt=week_ago)
        # list all the objects of streams created by current user
        following = UserFollow.objects.filter(follower=self.request.user).values_list('following', flat=True)
        current_user_following_streams = queryset.filter(created_by_id__in=following, type='Public',
                                                               status='Active', crd__gt=week_ago)
        # list all the objects of streams created by users followed by current user
        if isinstance(queryset, QuerySet):
            # Ensure queryset is re-evaluated on each request.
            queryset = current_user_streams | current_user_following_streams
        return queryset


class StarredAPI(ListAPIView):
    """"
    View to list all the starred streams of the logged in user.
    """

    queryset = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
        'created_by__user_data__user').prefetch_related(
        Prefetch(
            "stream_contents",
            queryset=StreamContent.objects.all().select_related('content',
                                                                'content__created_by__user_data').prefetch_related(
                Prefetch(
                    "content__content_like_dislike_status",
                    queryset=LikeDislikeContent.objects.filter(status=1),
                    to_attr='content_liked_user'
                )
            ).order_by('order', '-attached_date'),
            to_attr="content_list"
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator'
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator_verified'
        ),
        Prefetch(
            'stream_like_dislike_status',
            queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
                Prefetch(
                    "user__who_follows",
                    queryset=UserFollow.objects.all(),
                    to_attr='user_liked_followers'
                ),

            ),
            to_attr='total_like_dislike_data'
        ),
        Prefetch(
            'stream_user_view_status',
            queryset=StreamUserViewStatus.objects.all(),
            to_attr='total_view_count'
        )
    ).order_by('-id')
    starred_stream_queryset = StarredStream.objects.all()
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_backends = (filters.SearchFilter,)
    search_fields = ('name',)
    # filter_class = StarredStreamFilter

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):
        bookmarked_streams = self.starred_stream_queryset.filter(user=self.request.user).select_related('stream')
        queryset = self.filter_queryset(self.get_queryset())
        queryset = queryset.filter(id__in=[x.stream.id for x in bookmarked_streams])
        fields = (
            'id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update',
            'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator',
            'total_likes',
            'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo',
            'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.get_serializer_context())
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class NewEmogosAPI(ListAPIView):
    """"
    View to list all the New Emogos related to logged in user.
    """
    queryset = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
        'created_by__user_data__user').prefetch_related(
        Prefetch(
            "stream_contents",
            queryset=StreamContent.objects.all().select_related('content',
                                                                'content__created_by__user_data').prefetch_related(
                Prefetch(
                    "content__content_like_dislike_status",
                    queryset=LikeDislikeContent.objects.filter(status=1),
                    to_attr='content_liked_user'
                )
            ).order_by('order', '-attached_date'),
            to_attr="content_list"
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator'
        ),
        Prefetch(
            'collaborator_list',
            queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
            to_attr='stream_collaborator_verified'
        ),
        Prefetch(
            'stream_like_dislike_status',
            queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
                Prefetch(
                    "user__who_follows",
                    queryset=UserFollow.objects.all(),
                    to_attr='user_liked_followers'
                ),

            ),
            to_attr='total_like_dislike_data'
        ),
        Prefetch(
            'stream_user_view_status',
            queryset=StreamUserViewStatus.objects.all(),
            to_attr='total_view_count'
        )
    ).order_by('-id')
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_backends = (filters.SearchFilter,)
    search_fields = ('name',)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):
        fields = (
            'id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update',
            'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator',
            'total_likes',
            'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo',
            'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        serializer = self.get_serializer(queryset, many=True, fields=fields, context=self.get_serializer_context())
        if page is not None:
            serializer = self.get_serializer(page, many=True,fields=fields, context=self.get_serializer_context())
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def get_queryset(self):
        """
        Get the list of items for this view.
        This must be an iterable, and may be a queryset.
        Defaults to using `self.queryset`.

        This method should always be used rather than accessing `self.queryset`
        directly, as `self.queryset` gets evaluated only once, and those results
        are cached for all subsequent requests.

        You may want to override this if you need to provide different
        querysets depending on the incoming request.

        (Eg. return a list of items that is specific to the user)
        """
        assert self.queryset is not None, (
                "'%s' should either include a `queryset` attribute, "
                "or override the `get_queryset()` method."
                % self.__class__.__name__
        )

        queryset = self.queryset
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        current_user_streams = queryset.filter(created_by=self.request.user, status='Active', crd__gt=week_ago)
        # list all the objects of streams created by current user
        following = UserFollow.objects.filter(follower=self.request.user).values_list('following', flat=True)
        current_user_following_streams = queryset.filter(created_by_id__in=following, type='Public', status='Active', crd__gt=week_ago)
        # list all the objects of streams created by users followed by current user
        if isinstance(queryset, QuerySet):
            # Ensure queryset is re-evaluated on each request.
            queryset = current_user_streams | current_user_following_streams
        return queryset