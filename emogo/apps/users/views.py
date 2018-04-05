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
    UserResendOtpSerializer, UserProfileSerializer, GetTopStreamSerializer, VerifyOtpLoginSerializer, UserFollowSerializer
from emogo.apps.stream.serializers import StreamSerializer, ViewStreamSerializer
# constants
from emogo.constants import messages
# util method
from emogo.lib.helpers.utils import custom_render_response, send_otp
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from emogo.lib.custom_filters.filterset import UsersFilter
from emogo.apps.users.models import UserProfile, UserFollow
from emogo.apps.stream.models import Stream, Content, LikeDislikeStream, StreamUserViewStatus
from emogo.apps.collaborator.models import Collaborator
from django.shortcuts import get_object_or_404
from itertools import chain
# models
from django.contrib.auth.models import User
from django.db.models.query import QuerySet
from autofixtures import UserAutoFixture
from django.http import HttpResponse
from django.http import Http404
from django.db.models import Prefetch
from django.db.models import QuerySet


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
                fields = ("user_profile_id", "full_name", "user_image", "token", "user_id", "phone_number",
                          'location', 'website', 'birthday', 'biography', 'branchio_url')
                serializer = UserDetailSerializer(instance=instance, fields=fields)
                return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Login(APIView):
    """
    User login API
    """

    def post(self, request):
        serializer = UserLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate_user()
            fields = ("user_profile_id", "full_name", "useruser_image", "user_id", "phone_number", "user_image")
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
                return custom_render_response(status_code=status.HTTP_200_OK, data={"otp": user_pin})


class Users(CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView):
    """
    Users CRUD API
    """

    serializer_class = UserDetailSerializer
    queryset = UserProfile.actives.all().select_related('user').order_by('-id')
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

    def get_qs_object(self):
        qs = UserProfile.actives.filter(id=self.kwargs.get('pk')).select_related('user').select_related('profile_stream').prefetch_related(
            Prefetch(
                "user__who_follows",
                queryset=UserFollow.objects.all().order_by('-follow_time'),
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
        )
        return qs[0]

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get User profile API.
        """
        fields = ('user_profile_id', 'full_name', 'user_image', 'phone_number', 'location', 'website',
                  'biography', 'birthday', 'branchio_url', 'profile_stream', 'followers', 'following')
        instance = self.get_qs_object()
        # if self.request.user.id == instance.user.id:
        #     fields = list(fields)
        #     fields.append('contents')
        #     fields.append('collaborators')
        #     fields = tuple(fields)
        serializer = self.get_serializer(instance, fields=fields)
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        queryset = queryset.exclude(user=self.request.user)
        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'people', 'user_image', 'location', 'website',
                  'biography', 'birthday', 'branchio_url')
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
        self.serializer_class = UserProfileSerializer
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
        kwargs = dict()
        kwargs['type'] = 'Public'
        if request.data.get('user_id') =="":
            raise Http404("User profile does not exist")
        elif request.data.get('user_id') is not None:
            user_profile = get_object_or_404(UserProfile, id=request.data.get('user_id'), status='Active')
            kwargs['created_by'] = user_profile.user
            current_user = user_profile.user
        else:
            kwargs['created_by'] = self.request.user
            current_user = self.request.user

        stream_queryset = Stream.actives.filter(**kwargs).order_by('-id')
        collaborator_qs = Collaborator.actives.filter(created_by=current_user)
        collaborator_permission = [x.stream for x in collaborator_qs if
                                   str(x.phone_number) in str(self.request.user) and x.stream.status == 'Active']

        # merge result
        result_list = list(chain(stream_queryset, collaborator_permission))
        page = self.paginate_queryset(result_list)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class UserLikedSteams(ListAPIView):
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

    def get_queryset(self):
        qs = LikeDislikeStream.objects.filter(user=self.request.user).select_related('stream').prefetch_related('stream__stream_contents')
        return [x.stream for x in qs]

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


class UserCollaborators(ListAPIView):
    """
    User Collaborate Streams API
    """
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.all()

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
        collaborator_qs = Collaborator.actives.filter(stream__status='Active')
        streams = [x.stream.id for x in collaborator_qs if str(x.phone_number) in str(self.request.user.username) ]
        queryset = self.queryset
        if isinstance(queryset, QuerySet):
            # Ensure queryset is re-evaluated on each request.
            queryset = queryset.filter(id__in=streams)
        return queryset

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        # self.request.user
        self.serializer_class = ViewStreamSerializer
        queryset = self.filter_queryset(self.get_queryset())
        #  Customized field list
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True, fields=fields)
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

    def get(self, request):
        """
        Return a list of all users.
        """
        serializer = self.serializer_class(data=request.data, context=self.request)
        if serializer.is_valid():
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class VerifyLoginOTP(APIView):
    """
    User login API
    """

    def post(self, request):
        serializer = VerifyOtpLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate_login_OTP(request.data["otp"])
            fields = ("user_profile_id", "full_name", "useruser_image", "token", "user_id", "phone_number", "user_image",
                      'location', 'website', 'biography', 'birthday', 'branchio_url')
            serializer = UserDetailSerializer(instance=user_profile, fields=fields)
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class UserFollowAPI(CreateAPIView, DestroyAPIView):
    """
    User Streams API
    """
    serializer_class = UserFollowSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

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
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def perform_destroy(self, instance):
        UserFollow.objects.filter(following=instance, follower=self.request.user).delete()

    def perform_create(self, serializer):
        obj , created = UserFollow.objects.get_or_create(follower_id=self.request.data.get('follower'),
                                         following_id=self.request.data.get('following'))
        return obj
