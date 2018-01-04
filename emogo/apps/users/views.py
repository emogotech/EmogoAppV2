# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import transaction
from rest_framework import status
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
# django rest
from rest_framework.views import APIView
# serializer
from emogo.apps.users.serializers import UserSerializer, UserOtpSerializer, UserDetailSerializer, UserLoginSerializer, \
    UserResendOtpSerializer
from emogo.apps.stream.serializers import StreamSerializer
# constants
from emogo.constants import messages
# util method
from emogo.lib.helpers.utils import custom_render_response, send_otp
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from emogo.lib.custom_filters.filterset import UsersFilter
from emogo.apps.users.models import UserProfile
from emogo.apps.stream.models import Stream, Content
from emogo.apps.collaborator.models import Collaborator
from django.shortcuts import get_object_or_404
from itertools import chain
# models
from django.contrib.auth.models import User

class Signup(APIView):
    """
    User can register his detail and able to login in system.
    """
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                # Todo : For now we have commented send_otp code for development purpose
                # send_otp(request.data.get('phone_number'))
                serializer.create(serializer.validated_data)
                return custom_render_response(status_code=status.HTTP_201_CREATED, data={"otp": serializer.user_pin})


class VerifyRegistration(APIView):
    """
    This API to verify OTP.
    """

    def post(self, request):
        fields = ("otp", "phone_number", )
        serializer = UserOtpSerializer(data=request.data, fields=fields)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                instance = serializer.save()
                fields = ("user_profile_id", "full_name", "useruser_image", "token", "user_id", "phone_number")
                serializer = UserDetailSerializer(instance=instance, fields=fields)
                return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Login(APIView):
    """
    User login API
    """

    def post(self, request):
        serializer = UserLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate()
            fields = ("user_profile_id", "full_name", "useruser_image", "token", "user_id", "phone_number")
            serializer = UserDetailSerializer(instance=user_profile, fields=fields)
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Logout(APIView):
    """
    Use to logout from the system
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request):
        try:
            # simply delete the token to force a login
            request.user.auth_token.delete()
            message, status_code, response_status = messages.MSG_LOGOUT_SUCCESS, "200", status.HTTP_200_OK
            return custom_render_response(status_code, message, response_status)
        except:
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_OUT, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)


class UniqueUserName(APIView):
    """
    User unique name API
    """
    def post(self, request):
        serializer = UserSerializer(data=request.data, fields=('user_name',))
        if serializer.is_valid(raise_exception=True):
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class ResendOTP(APIView):
    """
    This API for sending an OTP.
    """
    def post(self, request):
        serializer = UserResendOtpSerializer(data=request.data, fields=('phone_number', ))
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                user_pin = serializer.resend_otp(request.data)
                # Todo : For now we have commented send_otp code for development purpose
                # send_otp(request.data.get('phone_number'))
                return custom_render_response(status_code=status.HTTP_200_OK, data={"otp": user_pin})


class Users(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Users CRUD API
    """

    serializer_class = UserDetailSerializer
    queryset = UserProfile.actives.all().order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_class = UsersFilter

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, *args, **kwargs):
        if kwargs.get('pk') is not None:
            return self.retrieve(self, request, *args, **kwargs)
        else:
            return self.list(request, *args, **kwargs)

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get User profile API.
        """
        fields = ('user_profile_id', 'full_name', 'user_image', 'phone_number', 'streams')
        instance = self.get_object()
        if self.request.user.id == instance.user.id:
            fields = list(fields)
            fields.append('contents')
            fields.append('collaborators')
            fields = tuple(fields)
        serializer = self.get_serializer(instance, fields=fields)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'people', 'user_image')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
        serializer = self.get_serializer(page, many=True, fields=fields)
        return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)

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


class UserSteams(ListAPIView):
    """
    User Streams API
    """
    serializer_class = StreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def post(self, request):
        try:
            kwargs = dict()
            logged_in_user = self.request.user.id
            logged_user = get_object_or_404(User, id=logged_in_user)
            if 'user_id' in request.data:
                user = get_object_or_404(User, id=request.data['user_id'])
                kwargs['created_by'] = user
            kwargs['type'] = 'Public'
            stream_queryset = Stream.objects.filter(**kwargs).order_by('-id')
            collab_stream_queryset = Stream.objects.filter(id__in=(Collaborator.objects.filter(phone_number=logged_user.username).values('stream_id')), type='Private')
            result_list = list(chain(stream_queryset, collab_stream_queryset))
            page = self.paginate_queryset(result_list)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
        except Exception as err:
            message, status_code, response_status = messages.MSG_ERROR_LIST, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)


class UserCollaborators(ListAPIView):
    """
    User Collaborate Streams API
    """
    serializer_class = StreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def post(self, request):
        try:
            user = get_object_or_404(User, id=self.request.user.id)
            queryset = Stream.objects.filter(id__in=(Collaborator.objects.filter(phone_number=user.username).values('stream_id'))).order_by('-id')
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
        except Exception as err:
            message, status_code, response_status = messages.MSG_ERROR_LIST, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)