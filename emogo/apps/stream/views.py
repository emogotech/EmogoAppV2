# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import status
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from emogo.lib.helpers.utils import custom_render_response
from models import Stream, Content, ExtremistReport, StreamContent
from serializers import StreamSerializer, ViewStreamSerializer, ContentSerializer, ViewContentSerializer, \
    ContentBulkDeleteSerializer, MoveContentToStreamSerializer, ExtremistReportSerializer, DeleteStreamContentSerializer
from emogo.lib.custom_filters.filterset import StreamFilter, ContentsFilter
from rest_framework.views import APIView
from django.core.urlresolvers import resolve


class StreamAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = StreamSerializer
    queryset = Stream.actives.all().order_by('-id')
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
            serializer = self.get_serializer(instance, fields=('collaborators',), context=self.request)
        # Return all data
        else:
            serializer = self.get_serializer(instance, context=self.request)
            # Update stream view count
            instance.update_view_count()

        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        self.serializer_class = ViewStreamSerializer
        queryset = self.filter_queryset(self.get_queryset())
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
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=None)


class ContentAPI(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ContentSerializer
    queryset = Content.actives.all().order_by('-upd')
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
        fields = ('id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image', 'height', 'width', 'color')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, many=True)
        serializer.is_valid(raise_exception=True)
        instances = serializer.create(serializer.validated_data)
        serializer = ViewContentSerializer(instances, many=True ,fields=('id', 'type', 'name', 'url', 'description', 'video_image', 'height', 'width'))
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


class ExtremistReportAPI(CreateAPIView):
    """
    Stream CRUD API
    """
    serializer_class = ExtremistReportSerializer
    queryset = ExtremistReport.objects.all()
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(dataa=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=self.request.data)
