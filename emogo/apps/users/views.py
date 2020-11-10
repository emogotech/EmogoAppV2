# -*- coding: utf-8 -*-


from django.db import transaction
from rest_framework import status
# from rest_framework.authentication import TokenAuthentication
from emogo.apps.users.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
# django rest
from rest_framework.views import APIView
# serializer
from emogo.apps.users.serializers import (
    UserSerializer, UserOtpSerializer, UserDetailSerializer, UserLoginSerializer,
    UserResendOtpSerializer, UserProfileSerializer, GetTopStreamSerializer,
    VerifyOtpLoginSerializer, UserFollowSerializer, UserListFollowerFollowingSerializer,
    CheckContactInEmogoSerializer, UserDeviceTokenSerializer, ViewGetTopStreamSerializer,
    OptimisedUserDetailSerializer)
from emogo.apps.stream.serializers import (
    StreamSerializer, ViewStreamSerializer, OptimisedViewStreamSerializer)
# constants
from emogo.constants import messages
# util method
from emogo.lib.helpers.utils import custom_render_response, send_otp
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from emogo.lib.custom_filters.filterset import (
    UsersFilter, UserStreamFilter, FollowerFollowingUserFilter, CollabsFilter,
    UserLikedStreamFilter)
from emogo.apps.users.models import UserProfile, UserFollow, UserDevice
from emogo.apps.stream.models import (
    Stream, Content, LikeDislikeStream, StreamUserViewStatus, StreamContent,
    LikeDislikeContent, StarredStream, NewEmogoViewStatusOnly, RecentUpdates,
    Folder, ContentComment)
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.notification.models import Notification
from emogo.apps.users.swagger_schema import (
    user_profile_update_schema_doc, user_profile_update_response, check_content_avail_schema,
    check_content_avail_responses, check_is_business_doc, verify_login_otp_schema,
    verify_login_otp_response, signup_schema_doc, verify_reg_schema_doc, login_api_response,
    login_schema_doc, logout_schema_doc, uniq_username_schema_doc)
from django.shortcuts import get_object_or_404
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from itertools import chain
# models
from django.contrib.auth.models import User
from django.db.models.query import QuerySet
from emogo.apps.users.autofixtures import UserAutoFixture
from django.http import HttpResponse
from django.http import Http404
from django.db.models import Prefetch, Count, OuterRef, Subquery
from django.db.models import QuerySet, Q, Exists
from emogo.apps.notification.views import NotificationAPI
import datetime
from django.db.models import Case, When, Q, IntegerField, OuterRef, Subquery
from emogo.apps.stream.serializers import RecentUpdatesSerializer, ContentSerializer, ViewContentSerializer, FolderSerializer
from rest_framework import serializers
from emogo.apps.users.models import Token
import collections
import boto3
import re
import threading
from django.conf import settings
from apns import APNs, Frame, Payload
from rest_framework import pagination
import json
from rest_framework.parsers import MultiPartParser, JSONParser
from botocore.exceptions import ClientError
from django.core.exceptions import ObjectDoesNotExist
from emogo.settings import content_type_till_v3
import logging
import random
import string
import os
import logging
# logger = logging.getLogger('watchtower-logger')
logger_name = logging.getLogger('email_log')


class Signup(APIView):
    """
    User can register his detail and able to login in system.
    """

    @swagger_auto_schema(
        request_body=signup_schema_doc,
        responses={'200': '{ "status_code": 201, "data": { } }'},
    )
    def post(self, request, version):
        logger_name.info("============= logger info")
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                # Todo : For now we have commented send_otp code for development purpose
                # send_otp(request.data.get('phone_number'))
                serializer.create(serializer.validated_data)
                return custom_render_response(status_code=status.HTTP_201_CREATED, data={})


class VerifyRegistration(APIView):
    """
    This API to verify OTP.
    """

    @swagger_auto_schema(
        request_body=verify_reg_schema_doc,
        responses=verify_login_otp_response
    )
    def post(self, request, version):
        # if not request.data.get("device_name", None):
        #     raise serializers.ValidationError({'device_name': ["device name is required."]})
        fields = ("otp", "phone_number", )
        serializer = UserOtpSerializer(data=request.data, fields=fields)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                instance, token = serializer.save(device_name=request.data.get("device_name"))
                user_profile = UserProfile.objects.select_related('user').prefetch_related( Prefetch( "user__who_follows", queryset=UserFollow.objects.all().order_by('-follow_time'), to_attr="followers" ), Prefetch( 'user__who_is_followed', queryset=UserFollow.objects.all().order_by('-follow_time'), to_attr='following' )).get(id = instance.id)
                fields = ("user_profile_id", "full_name", "user_image", "token", "user_id", "phone_number",
                          'location', 'website', 'birthday', 'biography', 'branchio_url', 'display_name', 'followers', 'following')
                serializer = UserDetailSerializer(instance=user_profile, fields=fields, context=self.request)
                serialize_data = serializer.data
                serialize_data.update({"token": token})
                return custom_render_response(status_code=status.HTTP_200_OK, data=serialize_data)


def get_device_data(user_tokens):
    temp_devices = ["device-1", "device-2", "device-3", "device-4", "device-5"]
    device_data = {}
    for token in user_tokens:
        if token.device_name:
            device_data.update({token.id: {
                "name": token.device_name, "date":token.created.strftime("%d/%m/%Y %H:%M")}})
        else:
            device_name = temp_devices.pop(0)
            device_data.update({token.id: {
                "name": device_name, "date":token.created.strftime("%d/%m/%Y %H:%M")}})
    return device_data


class Login(APIView):
    """
    User login API
    """

    @swagger_auto_schema(
        request_body=login_schema_doc,
        responses=login_api_response,
    )
    def post(self, request, version):
        serializer = UserLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate_user()
            fields = ("user_profile_id", "full_name", "useruser_image", "user_id", "phone_number", "user_image",
                      'display_name', 'followers', 'following')
            serializer = UserDetailSerializer(instance=user_profile, fields=fields, context=self.request)
            serialize_data = serializer.data
            user_tokens = Token.objects.only("device_name").filter(user=user_profile.user)
            if user_tokens.__len__() >= 5:
                serialize_data.update(
                    {"exceed_login_limit": True, "logged_in_devices": get_device_data(user_tokens)})
            else:
                serialize_data.update({"exceed_login_limit": False})
            return custom_render_response(status_code=status.HTTP_200_OK, data=serialize_data)


class UserLoggedInDevices(APIView):
    """
    Return logged in devices for the user 
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get(self, request, *args, **kwargs):
        user_tokens = Token.objects.only("device_name").filter(user=self.request.user)
        data = {"logged_in_devices": get_device_data(user_tokens)}
        return custom_render_response(status_code=status.HTTP_200_OK, data=data)


class Logout(APIView):
    """
    Use to logout from the system
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    @swagger_auto_schema(
        request_body=logout_schema_doc,
        responses={
            '200': '{"status_code": "200", "data": "Logout Successfully."}',
        },
    )
    def post(self, request, version):
        try:
            # simply delete the token to force a login
            if request.data.get("logout_from_all_device", False) == True:
                request.user.auth_tokens.all().delete()
            else:
                request.user.auth_tokens.filter(key=request.META.get(
                    'HTTP_AUTHORIZATION', b'').split()[1]).delete()
            message, status_code, response_status = messages.MSG_LOGOUT_SUCCESS, "200", status.HTTP_200_OK
            return custom_render_response(status_code, message, response_status)
        except:
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_OUT, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)


class UniqueUserName(APIView):
    """
    User unique name API
    """

    @swagger_auto_schema(
        request_body=uniq_username_schema_doc,
        responses={
            '200': """{"status_code": 200, "data": {"user_name": "swarnim" } }""",
        },
    )
    def post(self, request, version):
        serializer = UserSerializer(data=request.data, fields=('user_name',))
        if serializer.is_valid(raise_exception=True):
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class ResendOTP(APIView):
    """
    This API for sending an OTP.
    """

    @swagger_auto_schema(
        request_body=uniq_username_schema_doc,
        responses={
            '200': """{"status_code": 200, "data": {"otp": null } }""",
        },
    )
    def post(self, request, version):
        serializer = UserResendOtpSerializer(data=request.data, fields=('phone_number', ))
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                user_pin = serializer.resend_otp(request.data)
                return custom_render_response(status_code=status.HTTP_200_OK, data={"otp": user_pin})


class Users(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Users CRUD API
    """

    serializer_class = OptimisedUserDetailSerializer
    queryset = UserProfile.actives.all().select_related('user').order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_class = UsersFilter
    lookup_field= "user_id"

    def get_serializer_context(self):
        return {'request': self.request, 'context':self.request, 'version': self.kwargs.get('version')}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, *args, **kwargs):
        if kwargs.get('user_id') is not None:
            return self.retrieve(self, request, *args, **kwargs)
        else:
            return self.list(request, *args, **kwargs)

    def get_qs_object(self):
        try:
            return UserProfile.actives.select_related('user').select_related(
                'profile_stream').prefetch_related(
                Prefetch(
                    "user__who_follows",
                    queryset=UserFollow.objects.select_related(
                        "follower").order_by('-follow_time'),
                    to_attr="followers"
                ),
                Prefetch(
                    'user__who_is_followed',
                    queryset=UserFollow.objects.all().order_by('-follow_time'),
                    to_attr='following'
                ),
                Prefetch(
                    'profile_stream__stream_user_view_status',
                    queryset=StreamUserViewStatus.objects.all(),
                    to_attr='total_view_count'
                ),
                Prefetch(
                    'profile_stream__stream_like_dislike_status',
                    queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data'),
                    to_attr='total_like_dislike_data'
                ),
                Prefetch(
                    'profile_stream__collaborator_list',
                    queryset=Collaborator.actives.all().select_related('created_by').annotate(
                        collab_username=Subquery(
                        User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                        'username')[:1])).annotate(collab_fullname=Subquery(User.objects.filter(
                        username__endswith=OuterRef('phone_number')).values(
                        'user_data__full_name')[:1])).annotate(collab_userimage=Subquery(
                        User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                        'user_data__user_image')[:1])).annotate(collab_user_id=Subquery(
                        User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                        'id')[:1])).annotate(collab_userdata_id=Subquery(
                        User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                        'user_data__id')[:1])).order_by('-id'),
                    to_attr='profile_stream_collaborator_list'
                ),
                # Prefetch(
                #     'profile_stream__collaborator_list',
                #     queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
                #     to_attr='profile_stream_collaborator_verified'
                # ),
                Prefetch(
                    'profile_stream__stream_contents',
                    queryset=StreamContent.objects.all().select_related('content', 'content__created_by__user_data').prefetch_related(
                        Prefetch(
                            "content__content_like_dislike_status",
                            queryset=LikeDislikeContent.objects.filter(status=1),
                            to_attr='content_liked_user'
                        )
                    ).order_by('order', '-attached_date'),
                    to_attr="profile_stream_content_list"
                ),
                Prefetch(
                    'profile_stream__seen_stream',
                    queryset=NewEmogoViewStatusOnly.objects.all().select_related("user"),
                    to_attr='user_seen_streams'
                ),
            ).get(user_id=self.kwargs.get('user_id'))
        except ObjectDoesNotExist:
            raise Http404
        # if qs.__len__() > 0:
        #     return qs[0]
        # raise Http404

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get User profile API.
        """
        fields = ('user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower',
                  'user_image', 'phone_number', 'location', 'website', 'biography',
                  'birthday', 'branchio_url', 'profile_stream', 'followers', 'following',
                  'display_name', 'is_buisness_account', 'emogo_count')

        instance = self.get_qs_object()
        # If requested user is logged in user
        if instance.user == self.request.user:
            fields = fields + ( 'token', )
        serializer = self.get_serializer(instance, fields=fields, context=self.request)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        queryset = queryset.exclude(user=self.request.user)

        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'user_id', 'phone_number', 'people', 'user_image', 'location', 'website',
                  'biography', 'birthday', 'branchio_url', 'display_name')

        # This IF condition is added because if try to search by name or phone disable pagination class.
        if (self.request.query_params.get('name') or self.request.query_params.get('phone')) is not None:
            serializer = self.get_serializer(queryset, many=True, fields=fields)
            return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)
        else:
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True, fields=fields)
                return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)
            serializer = self.get_serializer(page, many=True, fields=fields)
            return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)

    @swagger_auto_schema(
        request_body=user_profile_update_schema_doc,
        responses=user_profile_update_response,
    )
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        """
        :param request: ALL request data
        :param args: request param as list
        :param kwargs: request param as dict
        :return: Update stream instance
        """
        self.serializer_class = UserProfileSerializer
        partial = kwargs.pop('partial', False)

        instance = self.get_object()
        fields = (
        'user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower',
        'user_image', 'phone_number', 'location', 'website', 'biography', 'birthday',
        'branchio_url', 'profile_stream', 'followers', 'following', 'display_name')

        # If requested user is logged in user
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        if getattr(instance, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}
            # If requested user is logged in user
        if instance.user == self.request.user:
            fields = fields + ('token',)

        serializer = OptimisedUserDetailSerializer(
            self.get_qs_object(), fields=fields, context=self.get_serializer_context())
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def delete_objects(self, image_array):
        """Delete multiple objects from an Amazon S3 bucket

        :param bucket_name: string
        :param object_names: list of strings
        :return: True if the referenced objects were deleted, otherwise False
        """

        # Convert list of object names to appropriate data format

        # Delete the objects
        s3 = boto3.resource('s3', aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                                aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY)
        try:
            for image in image_array:
                s3.Object(settings.AWS_BUCKET_NAME, image).delete()
        except:
            return False
        return True

    def delete(self, request, *args, **kwargs):
        # User delete API
        image_array = []
        queryset =  UserProfile.actives.get(user_id=request.user.id)
        for obj in queryset.user_streams():
            stream_img = obj.image
            if re.findall('http[s]?://s3.amazonaws.com+', stream_img):
                stream1 = stream_img.split('https://s3.amazonaws.com')[1].split('/')
                bucket_name1 = stream1[2] + '/' + stream1[3]
                if stream1[2] in ['testing', 'stream-media']:
                    image_array.append(bucket_name1)

        for obj1 in queryset.user_contents():
            # Delete stream,content image/video  from s3
            content_image = obj1.video_image
            if re.findall('http[s]?://s3.amazonaws.com+', content_image):
                content1 = content_image.split('https://s3.amazonaws.com')[1].split('/')
                bucket_name2 = content1[2] + '/' + content1[3]
                if content1[2] in ['testing', 'stream-media']:
                    image_array.append(bucket_name2)

            content_url = obj1.url
            if re.findall('http[s]?://s3.amazonaws.com+', content_url):
                content_url1 = content_url.split('https://s3.amazonaws.com')[1].split('/')
                content_bucket_url = content_url1[2] + '/' + content_url1[3]
                if content_url1[2] in ['testing', 'stream-media']:
                    image_array.append(content_bucket_url)

        user_img = queryset.user_image
        if re.findall('http[s]?://s3.amazonaws.com+', user_img):
            user_img1 = user_img.split('https://s3.amazonaws.com')[1].split('/')
            user_img_bucket = user_img1[2] + '/' + user_img1[3]
            if user_img1[2] in ['testing', 'stream-media']:
                image_array.append(user_img_bucket)

        request.user.delete()
        thread = threading.Thread(target=self.delete_objects,args=([image_array]))
        thread.start()
        return custom_render_response(status_code=status.HTTP_200_OK)


class UserStearms(ListAPIView):
    """
    User Streams API
    """
    swagger_schema = None
    serializer_class = StreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.filter().annotate(stream_view_count=Count('stream_user_view_status')).select_related('created_by__user_data__user').prefetch_related(
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
                queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data'),
                to_attr='total_like_dislike_data'
            ),
        ).order_by('-stream_view_count')
    filter_class = UserStreamFilter

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        self.serializer_class = ViewStreamSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators']
        if kwargs.get('version') == 'v3':
            fields.remove('collaborators')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class UserFollowersAPI(ListAPIView):
    """
    User Streams API
    """
    serializer_class = UserFollowSerializer
    authentication_classes = (TokenAuthentication,)
    queryset = UserFollow.objects.all().order_by('-id')
    filter_class = FollowerFollowingUserFilter
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):

        if request.GET.get('user_id'):
            qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(following=request.GET.get('user_id')).values_list('follower', flat=True))
        else:
            qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(following=self.request.user).values_list('follower', flat=True))

        qs = qs.select_related('user').prefetch_related(
                 Prefetch(
                    "user__who_follows",
                    queryset=UserFollow.objects.all().order_by('-follow_time'),
                    to_attr="follower_list"
            )
        )
        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'user_image', 'display_name', 'user_id', 'is_following', 'followers_count')
        self.serializer_class = UserListFollowerFollowingSerializer
        # self.queryset = qs

        # This IF condition is added because if try to search by name or phone disable pagination class.
        if (self.request.query_params.get('follower_phone') or self.request.query_params.get('follower_name')) is not None:
            serializer = self.get_serializer(qs, many=True, fields=fields)
            return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.request)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class UserFollowingAPI(ListAPIView):
    """
    User Streams API
    """
    serializer_class = UserFollowSerializer
    authentication_classes = (TokenAuthentication,)
    queryset = UserFollow.objects.all().select_related('following__user_data')
    filter_class = FollowerFollowingUserFilter
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def list(self, request, *args, **kwargs):
        if request.GET.get('user_id'):
            qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(follower=request.GET.get('user_id')).values_list('following', flat=True))
        else:
            qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(follower=self.request.user).values_list('following', flat=True))


        qs = qs.select_related('user').prefetch_related(
            Prefetch(
                "user__who_is_followed",
                queryset=UserFollow.objects.all().order_by('-follow_time'),
                to_attr="following_list"
            ),
            Prefetch(
                        "user__who_follows",
                        queryset=UserFollow.objects.all().order_by('-follow_time'),
                        to_attr="follower_list"
                            )
                    ).order_by('full_name')

        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'user_image', 'display_name', 'user_id', 'is_follower', 'following_count', 'followers_count')
        self.serializer_class = UserListFollowerFollowingSerializer

        # This IF condition is added because if try to search by name or phone disable pagination class.
        if (self.request.query_params.get('following_phone') or self.request.query_params.get(
                'following_name')) is not None:
            serializer = self.get_serializer(qs, many=True, fields=fields)
            return custom_render_response(data=serializer.data, status_code=status.HTTP_200_OK)

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class UserLikedSteams(ListAPIView):
    """
    User Streams API
    """
    serializer_class = OptimisedViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.all()
    filter_class = UserLikedStreamFilter

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def filter_queryset(self, queryset):
        """
        Given a queryset, filter it with whichever filter backend is in use.

        You are unlikely to want to override this method, although you may need
        to call it either from a list view, or from a custom `get_object`
        method if you want to apply the configured filtering backend to the
        default queryset.
        """
        # stream_ids_list = LikeDislikeStream.objects.filter(
        #     user=self.request.user, status=1).values_list('stream', flat=True).order_by(
        #         '-view_date')
        queryset = queryset.annotate(comments_status=Exists(
                ContentComment.actives.filter(stream=OuterRef("pk")))).filter(
            stream_like_dislike_status__user=self.request.user,
            stream_like_dislike_status__status=1).filter(
            Q(type="Public") | Q(Q(created_by=self.request.user) |
            Q(collaborator_list__phone_number__endswith=self.request.user.username[-10:],
            collaborator_list__status="Active"
            ))).select_related('created_by__user_data').prefetch_related(
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.actives.all().select_related('created_by').annotate(
                    collab_username=Subquery(
                    User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                    'username')[:1])).annotate(collab_fullname=Subquery(User.objects.filter(
                    username__endswith=OuterRef('phone_number')).values(
                    'user_data__full_name')[:1])).annotate(collab_userimage=Subquery(
                    User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                    'user_data__user_image')[:1])).annotate(collab_user_id=Subquery(
                    User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                    'id')[:1])).annotate(collab_userdata_id=Subquery(
                    User.objects.filter(username__endswith=OuterRef('phone_number')).values(
                    'user_data__id')[:1])).order_by('-id'),
                to_attr='stream_collaborator'
            ),
            # Prefetch(
            #     'collaborator_list',
            #     queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
            #     to_attr='stream_collaborator_verified'
            # ),
            Prefetch(
                "stream_contents",
                queryset=StreamContent.objects.all().select_related(
                    'content', 'content__created_by__user_data').prefetch_related(
                    Prefetch(
                        "content__content_like_dislike_status",
                        queryset=LikeDislikeContent.objects.filter(status=1),
                        to_attr='content_liked_user'
                    )
                ).order_by('order', '-attached_date'),
                to_attr="content_list"
            ),
            Prefetch(
                'stream_like_dislike_status',
                queryset=LikeDislikeStream.objects.filter(status=1).select_related(
                    'user__user_data').prefetch_related(
                    Prefetch(
                        "user__who_follows",
                        queryset=UserFollow.objects.select_related("follower").all(),
                        to_attr='user_liked_followers'
                    ),
                ),
                to_attr='total_like_dislike_data'
            ),
            Prefetch(
                'stream_starred',
                queryset=StarredStream.objects.all().select_related('user'),
                to_attr='total_starred_stream_data'
            ),
            Prefetch(
                'seen_stream',
                queryset=NewEmogoViewStatusOnly.objects.all().select_related("user"),
                to_attr='user_seen_streams'
            ),
        ).distinct()
        # non_converted = queryset
        # queryset = list(queryset)
        # stream_ids_list = list(stream_ids_list)
        # queryset.sort(key=lambda t: stream_ids_list.index(t.pk))
        return queryset

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        self.serializer_class = OptimisedViewStreamSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type',
                  'height', 'width', 'have_some_update', 'stream_permission', 'color',
                  'stream_contents', 'collaborator_permission', 'total_collaborator',
                  'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators',
                  'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description',
                  'status', 'liked', 'user_liked', 'collab_images',
                  'total_stream_collaborators', 'is_bookmarked', 'have_comments']
        if kwargs.get('version') == 'v3':
            fields.remove('collaborators')
        #Search in liked streams
        if request.GET.get('stream_name'):
            queryset = queryset.filter(name__icontains=request.GET['stream_name'])

        page = self.paginate_queryset(queryset.order_by(
            "-stream_like_dislike_status__view_date"))
        if page is not None:
            serializer = self.get_serializer(
                page, many=True, fields=fields, context=self.request)
            return self.get_paginated_response(
                data=serializer.data, status_code=status.HTTP_200_OK)


class UserCollaborators(ListAPIView):
    """
    User Collaborate Streams API
    """
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.all()
    filter_class = CollabsFilter

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

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

        # Ensure queryset is re-evaluated on each request.
        queryset = self.queryset.filter(id__in=Collaborator.actives.filter(
            phone_number__endswith=str(self.request.user.username)[-10:]).values_list(
            'stream_id', flat=True)).select_related(
                'created_by__user_data__user').prefetch_related(
        Prefetch(
            "stream_contents",
            queryset=StreamContent.objects.all().select_related('content').order_by('order' , '-attached_date').prefetch_related(
                Prefetch(
                    "content__content_like_dislike_status",
                    queryset=LikeDislikeContent.objects.filter(status=1),
                    to_attr='content_liked_user'
                )
            ),
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
            queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data'),
            to_attr='total_like_dislike_data'
        ),
        Prefetch(
            'stream_starred',
            queryset=StarredStream.objects.all().select_related('user'),
            to_attr='total_starred_stream_data'
        ),
        ).order_by('-id')
        return queryset

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        # self.request.user
        self.serializer_class = ViewStreamSerializer
        # Fetch all self created streams
        stream_ids = Collaborator.actives.filter(phone_number__endswith=str(
            self.request.user.username)[-10:]).values_list('stream', flat=True)
        #2. Fetch  stream Queryset objects as collaborators and exclude self.request.user created stream.
        queryset = self.filter_queryset(self.get_queryset().filter(
            id__in=stream_ids).exclude(created_by_id=self.request.user.id)).order_by('-upd')
        # Search stream by name
        if request.GET.get('name'):
            queryset = queryset.filter(name__icontains=request.GET.get('name'))

        qs = queryset

        starred_stream = qs.filter(id__in=stream_ids, stream_starred__id__isnull=False).exclude(created_by_id=self.request.user.id).order_by('-stream_starred__upd')
        # Get not starred stream in cronological order
        un_starred_stream = qs.filter(id__in=stream_ids, stream_starred__id__isnull=True).exclude(created_by_id=self.request.user.id).order_by('-upd')
        # Merge result
        queryset= []
        for obj in  list(chain(starred_stream, un_starred_stream)):
            if not obj in queryset:
                queryset.append(obj)

        #  Customized field list
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators', 'is_bookmarked']
        if kwargs.get('version') == 'v3':
            fields.remove('collaborators')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.get_serializer_context())
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class FixturesTestAPI(APIView):
    def get(self, request, format=None):
        """
        Return a list of all users.
        """
        UserAutoFixture(User, num_of_instances={}).create(1)
        return custom_render_response(status_code=200, data={})


def api_500(request):
    """
    :param request:
    :return: Automatically call while system generate 500 Error
    """
    response = HttpResponse('{"exception": "Internal server error.", "status_code": 500 }', content_type="application/json", status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return response


class GetTopStreamAPI(APIView):
    """
    View to list all users in the system.
    """
    serializer_class = GetTopStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    swagger_schema = None

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get(self, request, version, *args, **kwargs):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.get_serializer_context())
        if serializer.is_valid():
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class VerifyLoginOTP(APIView):
    """
    User login API
    """

    @swagger_auto_schema(
        request_body=verify_login_otp_schema,
        responses=verify_login_otp_response,
    )
    def post(self, request, version):
        # if not request.data.get("device_name", None):
        #     raise serializers.ValidationError({'device_name': ["device name is required."]})
        serializer = VerifyOtpLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile, token = serializer.authenticate_login_OTP(
                request.data["otp"], device_name=request.data.get("device_name"),
                device_to_logout=request.data.get("device_to_logout"))
            fields = ("user_profile_id", "full_name", "useruser_image", "token", "user_id", "phone_number", "user_image",
                      'location', 'website', 'biography', 'birthday', 'branchio_url', 'display_name', 'followers', 'following')
            serializer = UserDetailSerializer(instance=user_profile, fields=fields, context=self.request)
            serialize_data = serializer.data
            serialize_data.update({"token": token})
            return custom_render_response(status_code=status.HTTP_200_OK, data=serialize_data)


class UserFollowAPI(CreateAPIView, DestroyAPIView):
    """
    User Streams API
    """
    serializer_class = UserFollowSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = UserProfile.actives.select_related('user').prefetch_related(
            Prefetch( 
                "user__who_follows", 
                queryset=UserFollow.objects.all().order_by('-follow_time'), 
                to_attr="followers" 
            ),
            Prefetch(
                'user__who_is_followed', 
                queryset=UserFollow.objects.all().order_by('-follow_time'), 
                to_attr='following'
            )
        )

    @swagger_auto_schema(
        request_body=UserFollowSerializer(fields=["following"]),
        responses={
            '200': """{
                "status_code": 201,
                "data": {
                    "is_follower": false, "is_following": false, "following": 2,
                    "total_followers": 0, "total_following": 1
                }
            }""",
        },
    )
    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data, context=self.request)
        serializer.is_valid(raise_exception=True)
        # To return created stream data
        self.perform_create(serializer)
        if kwargs.get('version'):
            to_user = User.objects.get(id = self.request.data.get('following'))
            # NotificationAPI().send_notification(self.request.user, to_user, 'follower')
            thread = threading.Thread(
                target=NotificationAPI().send_notification, args=(
                    [self.request.user, to_user, 'follower']))
            thread.start()
        user_data = self.queryset.get(user_id=self.request.user)
        data = serializer.data
        data.update({'total_followers':user_data.user.followers.__len__(), 'total_following': user_data.user.following.__len__()})
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=data)

    def get_object(self):
        return get_object_or_404(UserFollow, follower=self.request.user, following_id=self.kwargs.get('pk'))

    def destroy(self, request,  *args, **kwargs):
        instance = self.get_object()
        noti = Notification.objects.filter(notification_type='follower', from_user=instance.follower, to_user=instance.following )
        if noti.__len__() > 0 :
            noti.delete()
        self.perform_destroy(instance)
        user_data = self.queryset.get(user_id=self.request.user)
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data={'followers':user_data.user.followers.__len__(), 'following':user_data.user.following.__len__()})

    def perform_create(self, serializer):
        obj, created = UserFollow.objects.get_or_create(follower=self.request.user,
                                                        following_id=self.request.data.get('following'))
        return obj


class CheckContactInEmogo(APIView):
    """
    Check contact list in emogo user.
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    serializer_class = CheckContactInEmogoSerializer

    @swagger_auto_schema(
        request_body=check_content_avail_schema,
        responses=check_content_avail_responses,
    )
    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid(raise_exception=True):

            data = serializer.find_contact_list()
            return custom_render_response(status_code=status.HTTP_200_OK, data=data)
        else:
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.errors)


class UserDeviceTokenAPI(CreateAPIView):
    """
    Add user device token
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    serializer_class = UserDeviceTokenSerializer


    def create(self, request, *args, **kwargs):
        """
        if user enable notification then set device token in userdevice
        if disabled then set device token to NULL
        :param request: device_token
        :return:Status 200 .
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        if serializer.is_valid():
            self.perform_create(serializer)
            return custom_render_response(status_code=status.HTTP_200_OK)
        else:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST, data=serializer.errors)


class GetTopStreamAPIV2(APIView):
    """
    View to list all users in the system.
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    swagger_schema = None


    def use_fields(self):
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'collab_images', 'total_stream_collaborators', 'is_bookmarked']
        return fields

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get(self, request, version, *args, **kwargs):
        """
        Return a list of all users.
        """
        qs = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
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
            ),
            Prefetch(
                    'stream_starred',
                    queryset=StarredStream.objects.all().select_related('user'),
                    to_attr='total_starred_stream_data'
                ),
            Prefetch(
                'seen_stream',
                queryset=NewEmogoViewStatusOnly.objects.filter().select_related('user'),
                to_attr='user_seen_streams'
            ),
        ).order_by('-id')

        queryset = [x for x in qs]
        # Featured Data
        featured = [x for x in queryset if x.featured]
        featured_serializer =  {"total": featured.__len__(), "data": ViewGetTopStreamSerializer(featured[0:10], many=True, fields=self.use_fields(), context=self.get_serializer_context()).data }

        # Emogo Data
        emogo = [x for x in queryset if x.emogo] 
        emogo_serializer = {"total": emogo.__len__(), "data": ViewGetTopStreamSerializer(emogo[0:10], many=True, fields=self.use_fields(), context=self.get_serializer_context()).data }

        # Popular Data
        popular_sort = sorted(queryset, key=lambda x: x.view_count, reverse=True)
        popular = [x for x in popular_sort if x.type == 'Public'] 
        if popular.__len__() < 10:
            # 1. Get user as collaborator in streams created by following's
            stream_ids = [x.stream.id for x in Collaborator.actives.select_related('stream').filter(phone_number=self.request.user.username, stream__status='Active', stream__type='Private')]
            # 2. Fetch stream Queryset objects.
            owner_qs = qs.filter(type='Public').order_by('-view_count')
            stream_as_collabs = qs.filter(id__in=stream_ids)  
            result_list = owner_qs | stream_as_collabs
            total = result_list.__len__()
            popular_list = result_list[0:10]
        else:
            total = popular.__len__()
            popular_list = popular[0:10]
        popular_serializer = {"total": total, "data": ViewGetTopStreamSerializer(popular_list, fields=self.use_fields(), many=True,  context = self.get_serializer_context()).data}
        
        #New Emogo Data
        following = UserFollow.objects.filter(follower=self.request.user).values_list('following', flat=True)
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        # list all the objects of streams created by current user
        recent_and_emogo_result_list = qs.filter(Q(created_by=self.request.user,)|Q(created_by_id__in=following,type='Public'), status='Active')
        emogo_list = recent_and_emogo_result_list.filter(crd__gt=week_ago)
        new_emogos = [x for x in emogo_list] 
        new_emogos_list = list(sorted(new_emogos, key=lambda x:
        [y.crd.date() for y in x.user_seen_streams if y.user == self.request.user][0] if [y.crd.date()  for y in  x.user_seen_streams if  y.user == self.request.user].__len__() > 0 else datetime.date.min))

        new_emogo_total = new_emogos_list.__len__()
        new_emogos_list = new_emogos_list[0:10]
        new_emogo_stream_serializer={"total": new_emogo_total, "data": ViewGetTopStreamSerializer(new_emogos_list, many=True, fields=self.use_fields().append('is_seen'), context=self.get_serializer_context()).data}

        #Get Booked Mark  Data
        user_bookmarks = StarredStream.objects.filter(user=self.request.user, stream__status='Active').select_related('stream').order_by('-id')
        pk_list = [x.stream.id for x in user_bookmarks]
        preserved = Case(*[When(pk=pk, then=pos) for pos, pk in enumerate(pk_list)])
        book_mark_result_list = qs.filter(id__in=pk_list).order_by(preserved)
        bookmark_total = book_mark_result_list.count()
        book_mark_result_list = book_mark_result_list[0:10]
        bookmarked_stream_serializer = {"total": bookmark_total, "data": ViewGetTopStreamSerializer(book_mark_result_list, many=True, fields=self.use_fields(),  context=self.get_serializer_context()).data}

        ## Recent updates in stream
        recent_result_list = list()
        recent_fields = (
        'user_image', 'first_content_cover', 'stream_name','stream_type', 'content_type', 'content_title', 'content_description',
        'content_width', 'content_height', 'content_color', 'added_by_user_id', 'user_profile_id', 'user_name',
        'seen_index', 'thread','total_added_content')
        # list all the objects of streams created by users followed by current user
        user_as_collaborator_streams = Collaborator.objects.filter(phone_number=self.request.user.username).values_list(
            'stream_id', flat=True)
        # list all the objects of streams where the current user is as collaborator.
        user_as_collaborator_active_streams = Stream.objects.filter(id__in=user_as_collaborator_streams,
                                                                    status="Active")
        # list all the objects of active streams where the current user is as collaborator.
        all_streams = recent_and_emogo_result_list | user_as_collaborator_active_streams
        content_ids = StreamContent.objects.filter(stream__in=all_streams, attached_date__gt=week_ago, user_id__isnull=False, thread__isnull=False).select_related('stream', 'content', 'user__user_data').prefetch_related( Prefetch('stream__recent_stream', queryset=RecentUpdates.objects.filter(user=self.request.user).order_by('seen_index'), to_attr='recent_updates'))

        grouped = collections.defaultdict(list)
        for item in content_ids:
            grouped[item.thread].append(item)
        return_list = list()
        for thread, group in list(grouped.items()):
            if group.__len__() > 0:
                setattr(group[0], 'total_added_contents', group.__len__())
                total_added_contents = group.__len__()
                if group[0].stream.recent_updates.__len__() > 0:
                    exact_current_seen_index = [x for x in group[0].stream.recent_updates if
                                                x.thread == group[0].thread]
                    if exact_current_seen_index.__len__() > 0:
                        setattr(group[0], 'exact_current_seen_index_row', exact_current_seen_index[0])
                return_list.append(group[0])

        have_seen_all_content = list()
        have_not_seen_all_content = list()
        for x in return_list:
            try:
                if x.exact_current_seen_index_row.seen_index >= (x.total_added_contents - 1):
                    have_seen_all_content.append(x)
                else:
                    have_not_seen_all_content.append(x)
            except AttributeError:
                have_not_seen_all_content.append(x)

        have_not_seen_all_content = list(sorted(have_not_seen_all_content, key=lambda a: a.attached_date, reverse=True))
        have_seen_all_content = list(
            sorted(have_seen_all_content, key=lambda a: a.exact_current_seen_index_row.seen_index))
        return_list = have_not_seen_all_content + have_seen_all_content
        total = return_list.__len__()
        recent_result_list = return_list[0:10]
        recent_result_serializer={"total": total, "data": RecentUpdatesSerializer(recent_result_list, many=True, fields=recent_fields).data}

        return custom_render_response(status_code=status.HTTP_200_OK, data={'featured':featured_serializer, 'emogo':emogo_serializer, 'popular':popular_serializer, 'new_emogo_stream':new_emogo_stream_serializer, 'bookmarked_stream':bookmarked_stream_serializer, "recent_update":recent_result_serializer })


class UserBuisnessAccount(APIView):
    """
    Update is_buisness_account flag API
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    @swagger_auto_schema(
        request_body=check_is_business_doc,
        responses={
            '200': """{ "status_code": 200, "data": { } }""",
        },
    )
    def post(self, request, version):
        UserProfile.objects.filter(user_id = request.user).update(is_buisness_account = request.data['is_buisness_account'])
        return custom_render_response(status_code = status.HTTP_200_OK)


class ContentPagination(pagination.PageNumberPagination):
       page_size = 27


class GetTopStreamAPIV3(ListAPIView):
    """
        View to list all users in the system.
        """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    pagination_class = ContentPagination
    swagger_schema = None


    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data)

    def use_fields(self):
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width',
                  'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission',
                  'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators',
                  'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked',
                  'collab_images', 'total_stream_collaborators', 'is_bookmarked']
        return fields

    def use_fields_follow(self):
        fields = ['user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower', 'user_image', 'phone_number', 'location', 'website',
                  'biography', 'birthday', 'branchio_url', 'followers', 'following', 'display_name', 'is_buisness_account', 'emogo_count']

        return fields

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs.get('version')}

    def get(self, request, version, *args, **kwargs):
        """
        Return a list of all users.
        """
        qs = Stream.actives.all().annotate(stream_view_count=Count('stream_user_view_status')).select_related(
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
            ),
            Prefetch(
                'stream_starred',
                queryset=StarredStream.objects.all().select_related('user'),
                to_attr='total_starred_stream_data'
            ),
            Prefetch(
                'seen_stream',
                queryset=NewEmogoViewStatusOnly.objects.filter().select_related('user'),
                to_attr='user_seen_streams'
            ),
        ).order_by('-id')

        queryset = [x for x in qs]
        # Featured Data
        featured = [x for x in queryset if x.featured]
        featured_serializer = {"total": featured.__len__(),
                               "data": ViewGetTopStreamSerializer(featured[0:10], many=True, fields=self.use_fields(),
                                                                  context=self.get_serializer_context()).data}

        featured_serializer['data'] = sorted(featured_serializer['data'],
                                                     key=lambda x: x['author'])

        following = UserFollow.objects.filter(follower=self.request.user).values_list('following', flat=True)
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        # list all the objects of streams created by current user
        recent_and_emogo_result_list = qs.filter(
            Q(created_by=self.request.user, ) | Q(created_by_id__in=following, type='Public'), status='Active')
        emogo_list = recent_and_emogo_result_list.filter(crd__gt=week_ago)

        recent_result_list = list()
        recent_fields = (
            'user_image', 'first_content_cover', 'stream_name', 'stream_type', 'content_type', 'content_title',
            'content_description',
            'content_width', 'content_height', 'content_color', 'added_by_user_id', 'user_profile_id', 'user_name',
            'seen_index', 'thread', 'total_added_content', 'video_image')
        # list all the objects of streams created by users followed by current user
        user_as_collaborator_streams = Collaborator.objects.filter(phone_number=self.request.user.username).values_list(
            'stream_id', flat=True)
        # list all the objects of streams where the current user is as collaborator.
        user_as_collaborator_active_streams = Stream.objects.filter(id__in=user_as_collaborator_streams,
                                                                    status="Active")

        all_streams = recent_and_emogo_result_list | user_as_collaborator_active_streams
        content_ids = StreamContent.objects.filter(stream__in=all_streams, attached_date__gt=week_ago,
                                                   user_id__isnull=False, thread__isnull=False).select_related('stream',
                                                                                                               'content',
                                                                                                               'user__user_data').prefetch_related(
            Prefetch('stream__recent_stream',
                     queryset=RecentUpdates.objects.filter(user=self.request.user).order_by('seen_index'),
                     to_attr='recent_updates'))

        grouped = collections.defaultdict(list)
        for item in content_ids:
            grouped[item.thread].append(item)
        return_list = list()
        for thread, group in list(grouped.items()):
            if group.__len__() > 0:
                setattr(group[0], 'total_added_contents', group.__len__())
                total_added_contents = group.__len__()
                if group[0].stream.recent_updates.__len__() > 0:
                    exact_current_seen_index = [x for x in group[0].stream.recent_updates if
                                                x.thread == group[0].thread]
                    if exact_current_seen_index.__len__() > 0:
                        setattr(group[0], 'exact_current_seen_index_row', exact_current_seen_index[0])
                return_list.append(group[0])

        have_seen_all_content = list()
        have_not_seen_all_content = list()
        for x in return_list:
            try:
                if x.exact_current_seen_index_row.seen_index >= (x.total_added_contents - 1):
                    have_seen_all_content.append(x)
                else:
                    have_not_seen_all_content.append(x)
            except AttributeError:
                have_not_seen_all_content.append(x)

        have_not_seen_all_content = list(sorted(have_not_seen_all_content, key=lambda a: a.attached_date, reverse=True))
        have_seen_all_content = list(
            sorted(have_seen_all_content, key=lambda a: a.exact_current_seen_index_row.seen_index))
        return_list = have_not_seen_all_content + have_seen_all_content
        total = return_list.__len__()
        recent_result_list = return_list[0:10]

        recent_result_serializer = {"total": total, "data": RecentUpdatesSerializer(recent_result_list, many=True,
                                                                                    fields=recent_fields).data}


        # Emogo Data
        emogo = [x for x in queryset if x.emogo]
        emogo_serializer = {"total": emogo.__len__(),
                            "data": ViewGetTopStreamSerializer(emogo[0:10], many=True, fields=self.use_fields(),
                                                               context=self.get_serializer_context()).data}

        #Content data
        fields = (
            'id', 'name', 'description', 'stream', 'url', 'type', 'created_by', 'video_image',
            'height', 'width', 'order', 'color', 'user_image', 'full_name', 'order', 'liked',
            'file', 'html_text')
        content_obj = Content.actives.filter(streams__type='Public').select_related('created_by__user_data__user').prefetch_related(
                    Prefetch(
                        "content_like_dislike_status",
                        queryset=LikeDislikeContent.objects.filter(status=1),
                        to_attr='content_liked_user'
                    )
                ).distinct().order_by('-upd')
        if self.kwargs.get('version') == 'v4':
            content_obj = content_obj
        else:
            content_obj = content_obj.filter(type__in=content_type_till_v3)
        obj = request.GET.get('page', 0)
        page = self.paginate_queryset(content_obj)
        if page is not None:
            content_result_serializer = {
                "data": ViewContentSerializer(page, many=True, fields=fields).data}

        if obj == '2':
            data = {
                    "featured": featured_serializer,
                    "content": content_result_serializer }

        elif obj == '3':
            suggested_user = UserProfile.actives.filter(is_suggested=True).exclude(user_id=self.request.user.id).prefetch_related(
                                Prefetch(
                                    "user__who_follows",
                                    queryset=UserFollow.objects.all(),
                                    to_attr="followers"
                                ),
                                Prefetch(
                                    'user__who_is_followed',
                                    queryset=UserFollow.objects.all(),
                                    to_attr='following'
                                )).order_by('full_name')

            suggested_follow_serializer = {"data":UserDetailSerializer(suggested_user[0:15], many = True, fields=self.use_fields_follow(),  context=self.request).data}
            suggested_follow_serializer['data'] = sorted(suggested_follow_serializer['data'], key=lambda x: x['is_following'])
            data = {
                    "suggested_follow": suggested_follow_serializer,
                    "content": content_result_serializer }

        elif obj:
            data = {"content": content_result_serializer}

        else:
            data = {"recent_update": recent_result_serializer, "content": content_result_serializer}

        return self.get_paginated_response(status_code=status.HTTP_200_OK,
                                          data=data)


class SuggestedFollowUser(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def use_fields_follow(self):
        fields = ['user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower',
                  'user_image', 'phone_number', 'location', 'website', 'biography',
                  'birthday', 'branchio_url', 'followers', 'following', 'display_name',
                  'is_buisness_account', 'emogo_count']
        return fields


    def get(self, request, *args, **kwargs):
        suggested_obj =  UserProfile.actives.filter(is_suggested=True).exclude(
            user_id=self.request.user.id).annotate(
                stream_counts=Count(Case(When(user__stream__status="Active", then=1),
                output_field=IntegerField()))).prefetch_related(
                    Prefetch(
                        "user__who_follows",
                        queryset=UserFollow.objects.all(),
                        to_attr="followers"
                    ),
                    Prefetch(
                        'user__who_is_followed',
                        queryset=UserFollow.objects.all(),
                        to_attr='following'
                    )).order_by('full_name')

        serializer = UserDetailSerializer(suggested_obj[0:15], many=True,fields=self.use_fields_follow(),  context=self.request)
        serializer = sorted(serializer.data, key=lambda x: x['is_following'])
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer)


class UserLeftMenuData(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_folder_data(self, data):
        fields = ("id", "name", "stream_count")
        folders = Folder.objects.filter(owner=self.request.user).annotate(stream_count=Count(Case(
                                                                            When(stream_folders__status="Active", then=1),
                                                                            output_field=IntegerField(),
                                                                          )))
        folder_serializer = FolderSerializer(folders, many=True, fields=fields)
        data["folders_count"] = folders.__len__()
        data["folder_data"] = folder_serializer.data
        return data

    def get(self, request, *args, **kwargs):
        # Fetch all self created streams
        try:
            shared_streams_count = json.loads(UserCollaborators.as_view()(request, version="v3").render().content).get('count')
        except Exception as e:
            shared_streams_count = 0

        # stream_ids = Collaborator.actives.filter(created_by_id=self.request.user.id).values_list('stream', flat=True)

        # 2. Fetch and return stream Queryset objects without collaborators.
        user_obj_data = User.objects.all().prefetch_related(
            Prefetch(
                "stream_set",
                queryset=Stream.actives.all(),
                to_attr="user_stream_data"
            ),
            Prefetch(
                "content_set",
                queryset=Content.actives.all(),
                to_attr="user_media_count"
            ),
            Prefetch(
                "content_set",
                queryset=Content.actives.filter(type="Link"),
                to_attr = "user_link_count"
            ),
            Prefetch(
                "content_set",
                queryset=Content.actives.filter(streams__id=None).prefetch_related("streams"),
                to_attr="user_not_yet_count"
            )).get(id=request.user.id)
        data = {
            "left_menu_data": {
                "user_stream_count": user_obj_data.user_stream_data.__len__(),
                "user_media_count": user_obj_data.user_media_count.__len__(),
                "user_media_link_count": user_obj_data.user_link_count.__len__(),
                "not_yet_added_content_count": user_obj_data.user_not_yet_count.__len__(),
                "shared_streams_count": shared_streams_count,
            }
        }
        data = self.get_folder_data(data)
        return custom_render_response(status_code=status.HTTP_200_OK, data=data)


class UploadMediaOnS3(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    parser_classes = (MultiPartParser,)
    swagger_schema = None

    def post(self, request, *args, **kwargs):
        s3_client = boto3.client('s3', aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                                 aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY)
        file = self.request.data.get("file", None)
        file_name = self.request.data.get("file_name", None)
        file_type = self.request.data.get("type", None)
        errors = {}
        if file and file_name and file_type:
            try:
                random_string = ''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(8))
                name, extension = os.path.splitext(file.name)
                final_file_name = file_name+random_string+extension
                url = "https://emogo-v2.s3.amazonaws.com/{}/{}".format(file_type, final_file_name)
                s3_client.upload_fileobj(file, "emogo-v2", "{}/{}".format(file_type, final_file_name))
                return custom_render_response(status_code=status.HTTP_200_OK, data={"file_url": url})
            except ClientError as e:
                print('Client Error')
                logging.error(e)
        else:
            if file is None:
                errors["file"] = "Media file is required."
            if file_name is None:
                errors["file_name"] = "File name is required."
            if file_type is None:
                errors["file_type"] = "File type is required."

        return custom_render_response(status_code=400, data={"Error": errors})
    
    
class TestNotification(APIView):
    """
    User login API
    """
    def post(self, request, version):
        #start notification
        device_token = request.data.get("device_token")
        token_hex = device_token
        path = settings.NOTIFICATION_PEM_ROOT
        apns = APNs(use_sandbox=settings.IS_SANDBOX, cert_file=path, key_file=path)
        msg = "Hello"
        payload = Payload(alert=msg, sound="default", badge=1)
        apns.gateway_server.send_notification(token_hex, payload)
        #stop notification
        return custom_render_response(status_code=200, data={"success": True})

   
