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
    UserResendOtpSerializer, UserProfileSerializer, GetTopStreamSerializer, VerifyOtpLoginSerializer, UserFollowSerializer, \
    UserListFollowerFollowingSerializer, CheckContactInEmogoSerializer, UserDeviceTokenSerializer
from emogo.apps.stream.serializers import StreamSerializer, ViewStreamSerializer
# constants
from emogo.constants import messages
# util method
from emogo.lib.helpers.utils import custom_render_response, send_otp
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from emogo.lib.custom_filters.filterset import UsersFilter, UserStreamFilter, FollowerFollowingUserFilter
from emogo.apps.users.models import UserProfile, UserFollow, UserDevice
from emogo.apps.stream.models import Stream, Content, LikeDislikeStream, StreamUserViewStatus, StreamContent, LikeDislikeContent
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.notification.models import Notification
from django.shortcuts import get_object_or_404
from itertools import chain
# models
from django.contrib.auth.models import User
from django.db.models.query import QuerySet
from autofixtures import UserAutoFixture
from django.http import HttpResponse
from django.http import Http404
from django.db.models import Prefetch, Count
from django.db.models import QuerySet, Q
from emogo.apps.notification.views import NotificationAPI


class Signup(APIView):
    """
    User can register his detail and able to login in system.
    """
    def post(self, request, version):
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

    def post(self, request, version):
        fields = ("otp", "phone_number", )
        serializer = UserOtpSerializer(data=request.data, fields=fields)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                instance = serializer.save()
                fields = ("user_profile_id", "full_name", "user_image", "token", "user_id", "phone_number",
                          'location', 'website', 'birthday', 'biography', 'branchio_url', 'display_name')
                serializer = UserDetailSerializer(instance=instance, fields=fields, context=self.request)
                return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Login(APIView):
    """
    User login API
    """

    def post(self, request, version):
        serializer = UserLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate_user()
            fields = ("user_profile_id", "full_name", "useruser_image", "user_id", "phone_number", "user_image", 'display_name')
            serializer = UserDetailSerializer(instance=user_profile, fields=fields, context=self.request)
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Logout(APIView):
    """
    Use to logout from the system
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request, version):
        try:
            # simply delete the token to force a login
            request.user.auth_token.delete()
            request.user.userdevice_set.all()[0].delete()
            message, status_code, response_status = messages.MSG_LOGOUT_SUCCESS, "200", status.HTTP_200_OK
            return custom_render_response(status_code, message, response_status)
        except:
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_OUT, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)


class UniqueUserName(APIView):
    """
    User unique name API
    """
    def post(self, request, version):
        serializer = UserSerializer(data=request.data, fields=('user_name',))
        if serializer.is_valid(raise_exception=True):
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class ResendOTP(APIView):
    """
    This API for sending an OTP.
    """
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

    serializer_class = UserDetailSerializer
    queryset = UserProfile.actives.all().select_related('user').order_by('-id')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    filter_class = UsersFilter
    lookup_field= "user_id"

    def get_serializer_context(self):
        return {'request': self.request, 'context':self.request, 'version': self.kwargs['version']}

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
        qs = UserProfile.actives.filter(user_id=self.kwargs.get('user_id')).select_related('user').select_related('profile_stream').prefetch_related(
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
            Prefetch(
                'profile_stream__collaborator_list',
                queryset=Collaborator.actives.all(),
                to_attr='profile_stream_collaborator_list'
            ),
            Prefetch(
                'profile_stream__collaborator_list',
                queryset=Collaborator.collab_actives.all().select_related('created_by').order_by('-id'),
                to_attr='profile_stream_collaborator_verified'
            ),
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
        )
        if qs.__len__() > 0:
            return qs[0]
        raise Http404

    def retrieve(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Get User profile API.
        """
        fields = ('user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower', 'user_image', 'phone_number', 'location', 'website',
                  'biography', 'birthday', 'branchio_url', 'profile_stream', 'followers', 'following', 'display_name')

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
        'user_profile_id', 'full_name', 'user_id', 'is_following', 'is_follower', 'user_image', 'phone_number',
        'location', 'website',
        'biography', 'birthday', 'branchio_url', 'profile_stream', 'followers', 'following', 'display_name')

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

        serializer = UserDetailSerializer(self.get_qs_object(), fields=fields, context=self.get_serializer_context())
        return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class UserStearms(ListAPIView):
    """
    User Streams API
    """
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
        return {'request': self.request, 'version': self.kwargs['version']}


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
        qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(following=self.request.user).values_list('follower', flat=True))
        qs = qs.select_related('user').prefetch_related(
                 Prefetch(
                    "user__who_follows",
                    queryset=UserFollow.objects.all().order_by('-follow_time'),
                    to_attr="follower_list"
            )
        )
        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'user_image', 'display_name', 'user_id', 'is_following')
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
        qs = UserProfile.actives.filter(user__in=self.filter_queryset(self.get_queryset()).filter(follower=self.request.user).values_list('following', flat=True))
        qs = qs.select_related('user').prefetch_related(
            Prefetch(
                "user__who_is_followed",
                queryset=UserFollow.objects.all().order_by('-follow_time'),
                to_attr="following_list"
            )
        )

        #  Customized field list
        fields = ('user_profile_id', 'full_name', 'phone_number', 'user_image', 'display_name', 'user_id', 'is_follower')
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
    serializer_class = StreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.all()
    
    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

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
        stream_ids_list = LikeDislikeStream.objects.filter(user=self.request.user, status=1).values_list('stream', flat=True).order_by('-view_date')
        queryset = queryset.filter(id__in=stream_ids_list).select_related('created_by__user_data').prefetch_related(
            Prefetch(
                'stream_user_view_status',
                queryset=StreamUserViewStatus.objects.all(),
                to_attr='total_view_count'
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
                to_attr='stream_collaborator'
            ),
            Prefetch(
                'collaborator_list',
                queryset=Collaborator.actives.all().select_related('created_by').order_by('-id'),
                to_attr='stream_collaborator_verified'
            ),
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
                'stream_like_dislike_status',
                queryset=LikeDislikeStream.objects.filter(status=1).select_related('user__user_data').prefetch_related(
                        Prefetch(
                            "user__who_follows",                            
                            queryset=UserFollow.objects.all(),
                            to_attr='user_liked_followers'                                   
                        ),

                ),
                to_attr='total_like_dislike_data'
            )
        ).order_by('-upd')
        queryset = list(queryset)
        # stream_ids_list = list(stream_ids_list)
        # queryset.sort(key=lambda t: stream_ids_list.index(t.pk))
        return queryset

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
            serializer = self.get_serializer(page, many=True, fields=fields, context=self.request)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class UserCollaborators(ListAPIView):
    """
    User Collaborate Streams API
    """
    serializer_class = ViewStreamSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    queryset = Stream.actives.all()

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

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
        queryset = self.queryset.filter(id__in=Collaborator.actives.filter(Q(phone_number= self.request.user.username )| Q(created_by_id=self.request.user.id) ).values_list('stream_id', flat=True)).select_related('created_by__user_data__user').prefetch_related(
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
        )).order_by('-id')
        return queryset

    def list(self, request, *args, **kwargs):
        #  Override serializer class : ViewStreamSerializer
        # self.request.user
        self.serializer_class = ViewStreamSerializer
        # Fetch all self created streams
        stream_ids = Collaborator.actives.filter(Q(created_by_id=self.request.user.id) | 
                                                    Q(phone_number__endswith=str(self.request.user.username)[-10:])).values_list( 'stream', flat=True)
        # # 2. Fetch  stream Queryset objects as collaborators.
        queryset =  self.get_queryset().filter(id__in=stream_ids).order_by('-upd')

        #  Customized field list
        fields = ['id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators']
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

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

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

    def post(self, request, version):
        serializer = VerifyOtpLoginSerializer(data=request.data, fields=('phone_number',))
        if serializer.is_valid(raise_exception=True):
            user_profile = serializer.authenticate_login_OTP(request.data["otp"])
            fields = ("user_profile_id", "full_name", "useruser_image", "token", "user_id", "phone_number", "user_image",
                      'location', 'website', 'biography', 'birthday', 'branchio_url', 'display_name')
            serializer = UserDetailSerializer(instance=user_profile, fields=fields, context=self.request)
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
        if version:
            to_user = User.objects.get(id = self.request.data.get('following'))
            NotificationAPI().send_notification(self.request.user, to_user, 'follower')
        return custom_render_response(status_code=status.HTTP_201_CREATED, data=serializer.data)

    def get_object(self):
        return get_object_or_404(UserFollow, follower=self.request.user, following_id=self.kwargs.get('pk'))

    def destroy(self, request,  *args, **kwargs):
        instance = self.get_object()
        noti = Notification.objects.filter(notification_type='follower', from_user=instance.follower, to_user=instance.following )
        if noti.__len__() > 0 :
            noti.delete()
        self.perform_destroy(instance)
        return custom_render_response(status_code=status.HTTP_204_NO_CONTENT, data=dict())

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

    def post(self, request, version):
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


    def create(self, request):
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
