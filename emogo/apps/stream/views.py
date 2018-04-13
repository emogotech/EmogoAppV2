# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.http import HttpResponse, HttpResponseRedirect, Http404
from rest_framework import status
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from emogo.lib.helpers.utils import custom_render_response
from models import Stream, Content, ExtremistReport, StreamContent, LikeDislikeStream, StreamUserViewStatus
from serializers import StreamSerializer, ViewStreamSerializer, ContentSerializer, ViewContentSerializer, \
    ContentBulkDeleteSerializer, MoveContentToStreamSerializer, ExtremistReportSerializer, DeleteStreamContentSerializer,\
    ReorderStreamContentSerializer, ReorderContentSerializer, StreamLikeDislikeSerializer
from emogo.lib.custom_filters.filterset import StreamFilter, ContentsFilter
from rest_framework.views import APIView
from django.core.urlresolvers import resolve
from django.shortcuts import get_object_or_404
import itertools
from emogo.apps.collaborator.models import Collaborator
from django.db.models import Prefetch
from django.db.models import QuerySet
from django.contrib.auth.models import User



class StreamAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = StreamSerializer
    queryset = Stream.actives.all().select_related('created_by__user_data__user').prefetch_related(
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

        ).order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'
    filter_class = StreamFilter

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, *args, **kwargs):
        if kwargs.get('pk') is not None:
            return self.retrieve(request, *args, **kwargs)
        else:
            return self.list(request, *args, **kwargs)

    def retrieve(self, request, *args, **kwargs):
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
        if current_url == 'stream_collaborator':
            user_data = User.objects.filter(username__in=[x.phone_number for x in instance.stream_collaborator]).values('username','user_data__user_image')
            self.request.data.update({'collab_user_image': user_data})
            serializer = self.get_serializer(instance, fields=('collaborators',), context=self.request)
        # Return all data
        else:
            serializer = self.get_serializer(instance, context=self.request)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        self.serializer_class = ViewStreamSerializer
        queryset = self.filter_queryset(self.queryset)
        #  Customized field list
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        stream = serializer.create(serializer.validated_data)
        # To return created stream data
        self.serializer_class = ViewStreamSerializer
        stream = self.queryset.filter(id=stream.id).prefetch_related('stream_contents', 'collaborator_list')[0]
        serializer = self.get_serializer(stream, context=self.request)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def update(self, request, *args, **kwargs):
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
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def destroy(self, request, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Soft Delete Stream and it's attribute
        """
        instance = self.get_object()
        # Perform delete operation
        self.perform_destroy(instance)
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


# Todo the DeleteStreamContentAPI is not used but it was keeped because it is using in last build.
class DeleteStreamContentAPI(DestroyAPIView):

    serializer_class = DeleteStreamContentSerializer
    queryset = Stream.actives.all().order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def destroy(self, request, *args, **kwargs):
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

    def post(self, request, *args, **kwargs):
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


class ContentAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ContentSerializer
    queryset = Content.actives.all().order_by('order')
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

    def get(self, request, *args, **kwargs):
        if kwargs.get('pk') is not None:
            return self.retrieve(request, *args, **kwargs)
        else:
            return self.list(request, *args, **kwargs)

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get Stream detail API.
        """
        #  Developer overwrite the self.get_object() method because any one can see content Detail
        instance = Content.actives.get(id=kwargs.get('pk'))
        self.serializer_class = ViewContentSerializer
        serializer = self.get_serializer(instance)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = (
        'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width', 'order',
        'color')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, many=True)
        serializer.is_valid(raise_exception=True)
        instances = serializer.create(serializer.validated_data)
        serializer = ViewContentSerializer(instances, many=True, fields=(
        'id', 'type', 'name', 'url', 'description', 'video_image', 'height', 'width'))
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def update(self, request, *args, **kwargs):
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
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def destroy(self, request, *args, **kwargs):
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
    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width',
            'order','color')
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        picture_type = self.get_serializer(queryset.filter(type='Picture')[0:10], many=True, fields=fields)
        video_type = self.get_serializer(queryset.filter(type='Video')[0:10], many=True, fields=fields)
        link_type = self.get_serializer(queryset.filter(type='Link')[0:10], many=True, fields=fields)
        giphy_type = self.get_serializer(queryset.filter(type='Giphy')[0:10], many=True, fields=fields)
        all = self.get_serializer(queryset[0:20], many=True, fields=fields)
        data = {'picture': picture_type.data, 'video': video_type.data, 'link': link_type.data,
                'giphy': giphy_type.data, 'all':all.data}
        return custom_render_response(data=data, status_code=status.HTTP_200_OK)


class GetTopTwentyContentAPI(ContentAPI):
    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width',
            'order', 'color')
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        final_qs = itertools.chain(queryset.filter(type='Link')[0:5], queryset.filter(type='Picture')[0:5],
                                   queryset.filter(type='Video')[0:5], queryset.filter(type='Giphy')[0:5])
        serializer = self.get_serializer(final_qs, many=True, fields=fields)
        return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)


class LinkTypeContentAPI(ListAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ContentSerializer
    queryset = Content.actives.all().order_by('-id')
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

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewContentSerializer
        self.serializer_class = ViewContentSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ('id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image','height', 'width')
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

    def post(self, request):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        self.queryset.filter(id__in=self.request.data['content_list']).update(status='Inactive')
        # Delete stream and content relation.
        StreamContent.objects.filter(content__in=self.request.data.get('content_list')).delete()
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


class MoveContentToStream(APIView):
    """
    View to list all users in the system.

    * Requires token authentication.
    * Only admin users are able to access this view.
    """
    serializer_class = MoveContentToStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
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

    def post(self, request):
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

    def post(self, request):
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

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=self.request.data)


class StreamLikeDislikeAPI(CreateAPIView):
    """
    Stream CRUD API
    """
    serializer_class = StreamLikeDislikeSerializer
    queryset = LikeDislikeStream.objects.all().order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'

    # def get_paginated_response(self, data, status_code=None):
    #     """
    #     Return a paginated style `Response` object for the given output data.
    #     """
    #     assert self.paginator is not None
    #     return self.paginator.get_paginated_response(data, status_code=status_code)

    # def get(self, request, *args, **kwargs):
    #     if kwargs.get('pk') is not None:
    #         return self.retrieve(request, *args, **kwargs)
    #     # else:
    #     #     return self.list(request, *args, **kwargs)

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