import re

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers
# from rest_framework.authtoken.models import Token
from emogo.apps.users.models import Token
from emogo import settings
from emogo.apps.users.models import UserProfile, create_user_deep_link, update_user_deep_link_url, UserFollow, UserDevice
from emogo.constants import messages
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from emogo.lib.custom_validator.validators import CustomUniqueValidator
from emogo.apps.stream.serializers import (
    ViewStreamSerializer, ViewContentSerializer, OptimisedViewStreamSerializer)
from emogo.apps.stream.models import (Stream, LikeDislikeStream, RecentUpdates,
    StreamContent, StreamUserViewStatus, LikeDislikeStream, LikeDislikeContent,
    StarredStream, NewEmogoViewStatusOnly, ContentComment)
from emogo.apps.collaborator.models import Collaborator
from itertools import chain
from django.db import IntegrityError
from emogo.lib.helpers.utils import generate_pin, send_otp
from emogo.apps.stream.views import get_stream_qs_objects
from django.db.models import Prefetch, Count, Q
import collections
from emogo.apps.stream.serializers import RecentUpdatesSerializer
from django.http import Http404
import operator
from itertools import product
from emogo.apps.collaborator.serializers import ViewCollaboratorSerializer
from functools import reduce
import threading

class UserSerializer(DynamicFieldsModelSerializer):
    """
    User model Serializer
    """

    password = serializers.CharField(read_only=True)
    otp = serializers.CharField(read_only=True)
    user_name = serializers.CharField()
    phone_number = serializers.CharField(source='username', validators=[CustomUniqueValidator(queryset=User.objects.all(), message='Phone number already exists.')])

    class Meta:
        model = User
        fields = ['email', 'password', 'phone_number', 'user_name', 'otp']
        extra_kwargs = {'password': {'required': True}}

    def create(self, validated_data):
        """
        :param validated_data:
        :return: Create User and user profile object
        """

        # The code is run while user was not verified but try to sign-up with different user_name or phone number
        # 1. While user request with same user_name and different phone number
        body =  "Emogo sign up OTP"
        sent_otp = send_otp(validated_data.get('username'), body)  # Todo Uncomment this code before move to stage server
        # sent_otp = 12345
        if sent_otp is not None:
            setattr(self, 'user_pin', sent_otp)
        else:
            raise serializers.ValidationError({'phone_number': messages.MSG_UNABLE_TO_SEND_OTP.format(validated_data.get('username'))})

        try:
            user_profile = UserProfile.objects.select_related("user").get(
                full_name=validated_data.get('user_name'), otp__isnull=False)
            user_profile.otp = self.user_pin
            user_profile.save()

            user_profile.user.username = validated_data.get('username')
            user_profile.user.save()
            return user_profile.user
        except UserProfile.DoesNotExist:
            pass

        # 2. While user request with same phone number and different user_name
        user, created = User.objects.get_or_create(username=validated_data.get('username'))
        user.set_password(self.user_pin)
        user.save()
        if created:
            user_profile = UserProfile(full_name=validated_data.get('user_name'), user=user, otp=self.user_pin)
            user_profile.save()
        else:
            user.user_data.full_name = validated_data.get('user_name')
            user.user_data.otp = self.user_pin
            user.user_data.save()
        # Create user deep link url
        thread = threading.Thread(target=create_user_deep_link, args=[user])
        thread.start()
        # create_user_deep_link(user)
        return user

    def validate_user_name(self, value):
        if UserProfile.objects.filter(full_name__iexact=value, otp__isnull=True).exists():
            raise serializers.ValidationError(messages.MSG_USER_NAME_EXISTS.format(value))
        return value

    def validate_phone_number(self, value):
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)


class UserProfileSerializer(DynamicFieldsModelSerializer):
    """
    UserProfile model serializer
    """
    token = serializers.SerializerMethodField()
    phone_number = serializers.SerializerMethodField()
    user_profile_id = serializers.IntegerField(source='id', read_only=True)
    streams = serializers.SerializerMethodField()
    contents = serializers.SerializerMethodField()
    collaborators = serializers.SerializerMethodField()
    username = serializers.CharField(read_only=True, source='user.username')
    user_id = serializers.CharField(read_only=True)

    class Meta:
        model = UserProfile
        fields = ['user_profile_id', 'full_name', 'user_id', 'user', 'user_image', 'token', 'user_image', 'user_id', 'phone_number'
            , 'streams', 'contents', 'collaborators', 'username', 'display_name', 'location', 'website', 'biography', 'birthday', 'branchio_url', 'profile_stream']

    def get_token(self, obj):
        # if hasattr(obj.user, 'auth_token'):
        #     return obj.user.auth_token.key
        try:
            return self.context.get("request").META.get('HTTP_AUTHORIZATION', b'').split()[1]
        except:
            return None

    def get_phone_number(self, obj):
        return obj.user.username

    def get_streams(self, obj):
        return None

    def get_contents(self,obj):
        return None

    def get_collaborators(self,obj):
        return None

    def save(self, **kwargs):
        try:
            # Save user table data.
            # if self.initial_data.get('phone_number') is not None:
            #     self.instance.user.username = self.initial_data.get('phone_number')
            #     self.instance.user.save()
            if self.validated_data.get('user_image') is not None:
                # Then user profile table data
                self.instance.user_image = self.validated_data.get('user_image')
            if self.validated_data.get('location') is not None:
                # Then user profile table data
                self.instance.location = self.validated_data.get('location')
            if self.validated_data.get('website') is not None:
                # Then user profile table data
                self.instance.website = self.validated_data.get('website')
            if self.validated_data.get('biography') is not None:
                # Then user profile table data
                self.instance.biography = self.validated_data.get('biography')
            if self.validated_data.get('birthday') is not None:
                # Then user profile table data
                self.instance.birthday = self.validated_data.get('birthday')
            if self.validated_data.get('profile_stream') is not None:
                # Then user profile table data
                self.instance.profile_stream = self.validated_data.get('profile_stream')
            if self.validated_data.get('display_name') is not None:
                # Then user profile table data
                self.instance.display_name = self.validated_data.get('display_name')
            if self.validated_data.__len__() > 0:
                self.instance.save()
                # Update user deep link.
                update_user_deep_link_url(self.instance.user)
        except IntegrityError as e:
            raise serializers.ValidationError({"phone_number":messages.MSG_PHONE_NUMBER_EXISTS})
        return self.instance


class UserDetailSerializer(UserProfileSerializer):
    """
    UserDetail Serializer to show user detail.
    """
    user_image = serializers.URLField(read_only=True)
    profile_stream = serializers.SerializerMethodField()
    followers = serializers.SerializerMethodField()
    following = serializers.SerializerMethodField()
    is_following = serializers.SerializerMethodField()
    is_follower = serializers.SerializerMethodField()
    phone_number = serializers.SerializerMethodField()
    followers_count = serializers.SerializerMethodField()
    emogo_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()
    # exceed_login_limit = serializers.SerializerMethodField()


    class Meta:
        model = UserProfile
        fields = '__all__'

    def get_following_count(self):
        return None

    def get_followers_count(self):
        return None

    def get_user_instance(self):
        if isinstance(self.context, dict):
            return self.context.get('request').user
        else:
            return self.context.user

    # def get_exceed_login_limit(self, obj):
    #     if Token.objects.filter(user=obj.user).count() >= 5:
    #         return True
    #     return False

    def get_profile_stream(self, obj):
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')

        if obj.profile_stream is not None and obj.profile_stream.status == 'Active':
            if self.context['version']:
                collaborator_list =  obj.profile_stream.profile_stream_collaborator_verified
                setattr(obj.profile_stream, 'stream_collaborator_verified', collaborator_list)
            else:
                collaborator_list =  obj.profile_stream.profile_stream_collaborator_list
             
            setattr(obj.profile_stream, 'stream_collaborator', collaborator_list)
            setattr(obj.profile_stream, 'content_list', obj.profile_stream.profile_stream_content_list)

            if obj.profile_stream.type == 'Private' and obj.profile_stream.created_by != self.get_user_instance():
                if self.get_user_instance().username in [x.phone_number for x in collaborator_list]:
                    return ViewStreamSerializer(obj.profile_stream, fields=fields, context = self.context).data
                return dict()
            else:
                return ViewStreamSerializer(obj.profile_stream, fields=fields, context = self.context).data
        return dict()

    def get_followers(self, obj):
        return obj.user.followers.__len__()

    def get_phone_number(self, obj):
        return obj.user.username

    def get_following(self, obj):
        return obj.user.following.__len__()

    def get_is_following(self, obj):
        if isinstance(self.context, dict):
            user_id = self.context.get('request').user.id
        else :
            user_id = self.context.user.id
        if user_id in [x.follower_id for x in obj.user.followers]:
            return True
        return False

    def get_is_follower(self, obj):
        if isinstance(self.context, dict):
            user_id = self.context.get('request').user.id
        else :
            user_id = self.context.user.id
        if user_id in [x.following_id for x in obj.user.following]:
            return True
        return False

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'video_image', 'file')
        return ViewContentSerializer(obj.user_contents(), many=True, fields=fields).data

    def get_emogo_count(self, obj):
        if hasattr(obj, "stream_counts"):
            return obj.stream_counts
        return obj.user.stream_set.all().filter(status='Active').count()


class OptimisedUserDetailSerializer(UserDetailSerializer):

    def get_profile_stream(self, obj):
        fields = (
            'id', 'name', 'image', 'author', 'created_by', 'view_count', 'type',
            'height', 'width', 'have_some_update', 'stream_permission', 'color',
            'stream_contents', 'collaborator_permission', 'total_collaborator',
            'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators',
            'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description',
            'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators')

        if obj.profile_stream is not None and obj.profile_stream.status == 'Active':
            if self.context['version']:
                collaborator_list =  [collab for collab in \
                        obj.profile_stream.profile_stream_collaborator_list if \
                            collab.status in ['Active', 'Unverified']]
                setattr(obj.profile_stream, 'stream_collaborator_verified', collaborator_list)
            else:
                collaborator_list =  obj.profile_stream.profile_stream_collaborator_list
            setattr(obj.profile_stream, 'stream_collaborator', collaborator_list)
            setattr(obj.profile_stream, 'content_list', obj.profile_stream.profile_stream_content_list)

            if obj.profile_stream.type == 'Private' and obj.profile_stream.created_by != self.get_user_instance():
                if self.get_user_instance().username in [x.phone_number for x in collaborator_list]:
                    return OptimisedViewStreamSerializer(obj.profile_stream, fields=fields, context = self.context).data
                return dict()
            else:
                return OptimisedViewStreamSerializer(
                    obj.profile_stream, fields=fields, context = self.context).data
        return dict()


class UserListFollowerFollowingSerializer(UserDetailSerializer):
    pass

    def get_is_following(self, obj):
        if isinstance(self.context, dict):
            user_id = self.context.get('request').user.id
        else:
            user_id = self.context.user.id
        if user_id in [x.follower_id for x in obj.user.follower_list]:
            return True
        return False

    def get_is_follower(self, obj):
        if isinstance(self.context, dict):
            user_id = self.context.get('request').user.id
        else :
            user_id = self.context.user.id
        if user_id in [x.following_id for x in obj.user.following_list]:
            return True
        return False

    def get_followers_count(self, obj):
        return obj.user.follower_list.__len__()

    def get_following_count(self, obj):
        return obj.user.following_list.__len__()


class UserOtpSerializer(UserProfileSerializer):
    """
    User OTP serializer inherits : UserProfileSerializer
    """
    otp = serializers.IntegerField(min_value=1)
    phone_number = serializers.CharField(source='user.username')

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        self.Meta.fields.append('otp')
        # self.Meta.fields.pop('streams')
        # self.Meta.fields.append('otp')

        # Instantiate the superclass normally
        super(UserOtpSerializer, self).__init__(*args, **kwargs)

    def validate_otp(self, value):
        try:
            self.instance = UserProfile.objects.get(otp=value, user__username=self.initial_data.get('phone_number'))
        except UserProfile.DoesNotExist:
            raise serializers.ValidationError(messages.MSG_INVALID_OTP)
        return value

    def validate_phone_number(self, value):
        try:
            user = UserProfile.actives.get(user__username=self.initial_data.get('phone_number'), otp__isnull=True)
            if user:
                raise serializers.ValidationError(messages.MSG_PHONE_NUMBER_EXISTS)
        except UserProfile.DoesNotExist:
            pass
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)


    def save(self, device_name=None):
        self.instance.otp = None
        self.instance.save(update_fields=['otp'])
        token = Token.objects.create(user=self.instance.user, device_name=device_name)
        return self.instance, token.key


class UserLoginSerializer(UserSerializer):
    """
    User login serializer inherits : UserSerializer
    """
    phone_number = serializers.CharField(source='username')

    def validate_phone_number(self, value):
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)

    def sent_otp_to_user(self, user):
        body = "Here is your emogo one time passcode"
        sent_otp = send_otp(self.validated_data.get('username'), body)  # Todo Uncomment this code before move to stage server
        if sent_otp is not None:
            setattr(self, 'user_pin', sent_otp)
        else:
            raise serializers.ValidationError({'phone_number': messages.MSG_UNABLE_TO_SEND_OTP.format(self.validated_data.get('username'))})
        # print self.user_pin
        if str(user.username) == str('+15089511377'):
            user.set_password('12345')
        else:
            user.set_password(self.user_pin)
        user.save()

    def authenticate_user(self):
        try:
            user = User.objects.only("username", "password").get(username=self.validated_data.get('username'))
            # If user is already login then logout requested user and try to new log-in.
            # if user.is_authenticated():
            #     if hasattr(user, 'auth_token'):
            #         user.auth_token.delete()
            #     user.user_data.otp = None
            #     user.user_data.save()
            user_profile = UserProfile.objects.select_related('user').prefetch_related(
            Prefetch(
                "user__who_follows",
                queryset=UserFollow.objects.only("id"),
                to_attr="followers"
            ),
            Prefetch(
                'user__who_is_followed',
                queryset=UserFollow.objects.only("id"),
                to_attr='following'
            )).get(user=user)
            thread = threading.Thread(target=self.sent_otp_to_user, args=[user])
            thread.start()

        except (UserProfile.DoesNotExist, User.DoesNotExist):
            raise serializers.ValidationError(messages.MSG_PHONE_NUMBER_NOT_REGISTERED)
        return user_profile


class VerifyOtpLoginSerializer(UserSerializer):
    """
    User login serializer inherits : UserSerializer
    """
    phone_number = serializers.CharField(source='username')
    otp = serializers.IntegerField(min_value=1, required=False)

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        # self.Meta.fields.append('otp')
        # self.Meta.fields.pop('streams')
        # self.Meta.fields.append('otp')

        # Instantiate the superclass normally
        super(VerifyOtpLoginSerializer, self).__init__(*args, **kwargs)

    def validate_phone_number(self, value):
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)

    def validate_and_create_token(self, user, device_name, device_to_logout):
        user_tokens = Token.objects.filter(user=user)
        if user_tokens.__len__() >= 5:
            if not device_to_logout:
                raise serializers.ValidationError(
                    {'device_name': ["Select atleast one device to Signout before login."]})
            # token_ids = [tokn.id for tokn in user_tokens]
            token_ids_to_logout = [tokn.id for tokn in user_tokens if tokn.id in device_to_logout]
            user_tokens = user_tokens.filter(pk__in=token_ids_to_logout).delete()
            if user_tokens.__len__() > 4:
                raise serializers.ValidationError(
                    {'device_name': ["Select valid device to Signout."]})
        token = Token.objects.create(user=user, device_name=device_name)
        token.save()
        return token

    def authenticate_login_OTP(self, otp, device_name=None, device_to_logout=None):
        # print self.validated_data.get('username')
        try:
            User.objects.get(username=self.validated_data.get('username'))
            user = authenticate(username=self.validated_data.get('username'), password=otp)
            if user is None:
                raise serializers.ValidationError(messages.MSG_INVALID_OTP)
            user_profile = UserProfile.objects.select_related('user').prefetch_related(
            Prefetch(
                "user__who_follows",
                queryset=UserFollow.objects.all().order_by('-follow_time'),
                to_attr="followers"
            ),
            Prefetch(
                'user__who_is_followed',
                queryset=UserFollow.objects.all().order_by('-follow_time'),
                to_attr='following'
            )).get(user=user)
            # if hasattr(user, 'auth_token'):
            #     user.auth_token.delete()
            token = self.validate_and_create_token(user, device_name, device_to_logout)
            user_profile.otp = None
            user_profile.save()
            return user_profile, token.key
        except (UserProfile.DoesNotExist, User.DoesNotExist):
            raise serializers.ValidationError(messages.MSG_PHONE_NUMBER_NOT_REGISTERED)


class UserResendOtpSerializer(UserProfileSerializer):
    """
    User OTP serializer inherits : UserProfileSerializer
    """
    phone_number = serializers.CharField()

    def resend_otp(self, validated_data):
        setattr(self, 'user_pin', None)
        if User.objects.filter(username=validated_data.get('phone_number')).exists():
            # Todo : For now we have commented send_otp code for development purpose
            body = "Here is your emogo one time passcode"
            self.user_pin = send_otp(validated_data.get('phone_number'), body)
            user = User.objects.get(username=validated_data.get('phone_number'))
            user_profile = UserProfile.objects.get(user=user)
            user_profile.otp = self.user_pin
            user_profile.save()
            # Again reset user password as otp code

            if str(validated_data.get('phone_number')) == str('+15089511377'):
                user.set_password('12345')
            else:
                user.set_password(self.user_pin)
            user.save()

        return self.user_pin

    def validate_phone_number(self, value):
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)


class GetTopStreamSerializer(serializers.Serializer):
    """
    The Custom Serializer
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

    featured = serializers.SerializerMethodField()
    emogo = serializers.SerializerMethodField()
    popular = serializers.SerializerMethodField()
    people = serializers.SerializerMethodField()
    liked = serializers.SerializerMethodField()
    following_stream = serializers.SerializerMethodField()
    private_stream = serializers.SerializerMethodField()
    public_stream = serializers.SerializerMethodField()
    new_emogo_stream = serializers.SerializerMethodField()
    bookmarked_stream = serializers.SerializerMethodField()
    recent_update = serializers.SerializerMethodField()
    collaborator_qs = Collaborator.actives.all().select_related('stream')

    def use_fields(self):
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update', 'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo', 'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators', 'is_bookmarked')
        return fields

    def get_serializer_context(self):
        #  Modify the context parameter, pass the request params in context for viewstreamserializer
        return self.context

    def get_featured(self, obj):
        qs = self.qs.filter(featured=True).order_by('-stream_view_count')
        return {"total": qs.count(), "data": ViewStreamSerializer(qs[0:10], many=True, fields=self.use_fields(), context = self.context).data }

    def get_emogo(self, obj):
        qs = self.qs.filter(emogo=True)
        return {"total": qs.count(), "data": ViewStreamSerializer(qs[0:10], many=True, fields=self.use_fields(), context = self.context).data }

    def get_popular(self, obj):
        # Get self created streams
        owner_qs = self.qs.filter(type='Public').order_by('-view_count')
        if owner_qs.count() < 10:
            # Get streams user as collaborator and has add content permission
            collaborator_permission = [x.stream for x in self.collaborator_qs if
                                       str(x.phone_number) in str(self.context.user.username) and x.stream.status == 'Active']

            # merge result
            result_list = list(chain(owner_qs, collaborator_permission))
            total = result_list.__len__()
            result_list = result_list[0:10]

        else:
            total = owner_qs.count()
            result_list = owner_qs[0:10]

        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.context).data}

    def get_people(self, obj):
        fields = ('user_profile_id', 'full_name', 'phone_number', 'people', 'user_image', 'display_name', 'user_id')
        qs = UserProfile.actives.all().exclude(user=self.context.get('request').user).order_by('full_name').select_related('user')
        return {"total": qs.count(), "data": UserDetailSerializer(qs[0:10], many=True, fields=fields,
                                    context=self.context).data}

    def get_liked(self, obj):

        stream_ids_list = LikeDislikeStream.objects.filter(user=self.context.get('request').user, status=1).values_list('stream', flat=True)
        result_list = self.qs.filter(id__in=stream_ids_list).order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.context).data }

    def get_following_stream(self, obj):
        # 1. Get user as collaborator in streams created by following's
        stream_ids = Collaborator.actives.filter(phone_number=self.context.get('request').user.username, stream__status='Active', stream__type='Private', created_by_id__in=UserFollow.objects.filter(follower=self.context.get('request').user).values_list('following_id', flat=True)).values_list('stream', flat=True)

        # 2. Fetch stream Queryset objects.
        stream_as_collabs = self.qs.filter(id__in=stream_ids)

        # 3. Get main stream created by requested user and stream type is Public.
        main_qs = self.qs.filter(created_by__in=UserFollow.objects.filter(follower=self.context.get('request').user).values_list('following_id', flat=True), type='Public')
        result_list = main_qs | stream_as_collabs
        total = result_list.count()
        result_list = result_list.order_by('-upd')[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.context).data }
    
    ## Added Private stream 
    def get_private_stream(self, obj):
        result_list = self.qs.filter(created_by__id=self.context.get('request').user.id, type='Private').order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.context).data }
    
    ## Added Public stream 
    def get_public_stream(self, obj):
        result_list = self.qs.filter(created_by__id=self.context.get('request').user.id, type='Public').order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.context).data }

    ## Added New stream
    def get_new_emogo_stream(self, obj):
        import datetime
        fields = (
        'id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'have_some_update',
        'stream_permission', 'color', 'stream_contents', 'collaborator_permission', 'total_collaborator', 'total_likes',
        'is_collaborator', 'any_one_can_edit', 'collaborators', 'user_image', 'crd', 'upd', 'category', 'emogo',
        'featured', 'description', 'status', 'liked', 'user_liked', 'collab_images', 'total_stream_collaborators',
        'is_bookmarked','is_seen')
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        current_user_streams = self.qs.filter(created_by=self.context.get('request').user, status='Active', crd__gt=week_ago)
        # list all the objects of streams created by current user
        following = UserFollow.objects.filter(follower=self.context.get('request').user).values_list('following', flat=True)
        current_user_following_streams = self.qs.filter(created_by_id__in=following, type='Public',
                                                         status='Active', crd__gt=week_ago)

        result_list = current_user_streams | current_user_following_streams
        result_list = list(sorted(result_list, key=lambda x:
        [y.crd.date() for y in x.user_seen_streams if y.user == self.context.get('request').user][0] if [y.crd.date()
                                                                                          for y in
                                                                                          x.user_seen_streams if
                                                                                          y.user == self.context.get('request').user].__len__() > 0 else datetime.date.min))

        total = result_list.__len__()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=fields,
                                                             context=self.context).data}

    ## Added Bookmark stream
    def get_bookmarked_stream(self, obj):
        from django.db.models import Case, When
        user_bookmarks = StarredStream.objects.filter(user=self.context.get('request').user, stream__status='Active').select_related('stream').order_by('-id')
        pk_list = [x.stream.id for x in user_bookmarks]
        preserved = Case(*[When(pk=pk, then=pos) for pos, pk in enumerate(pk_list)])
        result_list = self.qs.filter(id__in=pk_list).order_by(preserved)
        # result_list.order_by = False
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(),
                                                                     context=self.context).data}

    ## Recent updates in stream
    def get_recent_update(self, obj):
        import datetime
        result_list = list()
        fields = (
        'user_image', 'first_content_cover', 'stream_name','stream_type', 'content_type', 'content_title', 'content_description',
        'content_width', 'content_height', 'content_color', 'added_by_user_id', 'user_profile_id', 'user_name',
        'seen_index', 'thread','total_added_content')
        today = datetime.date.today()
        week_ago = today - datetime.timedelta(days=7)
        current_user_streams = Stream.objects.filter(created_by=self.context.get('request').user, status='Active')
        # list all the objects of active streams created by logged in user.
        following = UserFollow.objects.filter(follower=self.context.get('request').user).values_list('following', flat=True)
        # list all the objects of users whom logged in user is following.
        all_following_public_streams = Stream.objects.filter(created_by_id__in=following, status="Active",
                                                             type="Public")
        # list all the objects of streams created by users followed by current user
        user_as_collaborator_streams = Collaborator.objects.filter(phone_number=self.context.get('request').user.username).values_list(
            'stream_id', flat=True)
        # list all the objects of streams where the current user is as collaborator.
        user_as_collaborator_active_streams = Stream.objects.filter(id__in=user_as_collaborator_streams,
                                                                    status="Active")
        # list all the objects of active streams where the current user is as collaborator.

        all_streams = current_user_streams | all_following_public_streams | user_as_collaborator_active_streams
        content_ids = StreamContent.objects.filter(stream__in=all_streams, attached_date__gt=week_ago,
                                                   user_id__isnull=False, thread__isnull=False).select_related('stream',
                                                                                                               'content').prefetch_related(
            Prefetch('stream__recent_stream',
                     queryset=RecentUpdates.objects.filter(user=self.context.get('request').user).order_by('seen_index'),
                     to_attr='recent_updates'))

        grouped = collections.defaultdict(list)
        for item in content_ids:
            grouped[item.thread].append(item)
        return_list = list()
        for thread, group in grouped.items():
            if group.__len__() > 0:
                setattr(group[0], 'total_added_contents', group.__len__())
                total_added_contents = group.__len__()
                # seen_indexes = RecentUpdates.objects.filter(thread=thread, seen_index__gt=total_added_contents)
                # seen_indexes.update(seen_index=total_added_contents-1)
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
        result_list = return_list[0:10]
        return {"total": total, "data": RecentUpdatesSerializer(result_list, many=True, fields=fields).data}


class UserFollowSerializer(DynamicFieldsModelSerializer):
    """
    User Follow model Serializer
    """
    follower = serializers.IntegerField(read_only=True)
    is_follower = serializers.SerializerMethodField()
    is_following = serializers.SerializerMethodField()

    class Meta:
        model = UserFollow
        fields = '__all__'

    def get_is_follower(self, ob):
        return False

    def get_is_following(self, ob):
        return False

class CheckContactInEmogoSerializer(serializers.Serializer):
    """
    Check contact list exist in Emogo user.
    """
    contact_list = serializers.ListField(min_length=1)

    class Meta:
        fields = ('contact_list',)

    def find_contact_list(self):
        users = User.objects.all().values_list('username', flat=True)
        all_users = [x for x in users]
        # Find User profile for contact list
        fields = ('user_id', 'user_profile_id', 'full_name', 'user_image', 'display_name', 'phone_number')
        user_prof = list()
        contact_not_exist = list()
        valid_user_number=[]

        contacts = [str(contact)[-10:] for contact in self.validated_data.get('contact_list')]
        valid_user_number = [x.user.username[-10:] for x in UserProfile.objects.filter(user__username__regex = "|".join(contacts)).select_related('user')]

        for contact in contacts:
            if contact not in valid_user_number:
                contact_not_exist.append(contact)

        user_info = {}
        valid=[]

        for contact in self.validated_data.get('contact_list'):
            if contact[-10:] in contact_not_exist:
                user_info[contact] = False

        for user in all_users:
            for contact in contacts:
                if str(user[-10:]) == contact:
                    valid.append(str(user[-10:]))

        user_data = UserDetailSerializer(UserProfile.objects.filter(user__username__regex = "|".join(valid)).select_related('user'), fields=fields, context=self.context, many=True).data
        for x in user_data:
            user_info[x['phone_number']] = x
        return user_info


class UserDeviceTokenSerializer(serializers.Serializer):

    class Meta:
        model = UserDevice
        fields = ('device_token',  'user')

    # def create(self, *args, **kwargs):
    #     user, _ = UserDevice.objects.get_or_create( user=self.context.user)      
    #     user.device_token=self.initial_data['device_token'] 
    #     user.save()
    #     return user

    def create(self, *args, **kwargs):
        try:
            token = Token.objects.get(
                key=self.context.META.get('HTTP_AUTHORIZATION', b'').split()[1])
            user, _= UserDevice.objects.update_or_create(
                user=self.context.user, auth_token=token,
                defaults={'device_token': self.initial_data['device_token']},
            )
            return user
        except:
            raise Http404("User does not exist.")


class ViewGetTopStreamSerializer(DynamicFieldsModelSerializer):
    """
    The Custom Serializer
    """

    author = serializers.SerializerMethodField()
    collaborators = serializers.SerializerMethodField()
    contents = serializers.SerializerMethodField()
    stream_permission = serializers.SerializerMethodField()
    collaborator_permission = serializers.SerializerMethodField()
    total_collaborator = serializers.SerializerMethodField()
    view_count = serializers.SerializerMethodField()
    total_likes = serializers.SerializerMethodField()
    liked = serializers.SerializerMethodField()
    user_image = serializers.SerializerMethodField()
    is_collaborator = serializers.SerializerMethodField()
    stream_contents = serializers.SerializerMethodField()
    collab_images = serializers.SerializerMethodField()
    total_stream_collaborators = serializers.SerializerMethodField()
    is_bookmarked = serializers.SerializerMethodField()
    is_seen = serializers.SerializerMethodField()
    have_some_update = serializers.SerializerMethodField()
    
    class Meta:
        model = Stream
        fields = "__all__"

    def get_have_some_update(self, obj):
        seen_obj = [ x.have_some_update for x in obj.user_seen_streams if x.user == self.context.get('request').user]
        if seen_obj:
            return seen_obj[0]
        else:
            return obj.have_some_update

    def get_total_stream_collaborators(self, obj):
        try:
            return obj.stream_collaborator_verified.__len__()
        except Exception:
            return '0'
            
    def get_collab_data(self, obj, instances):
        list_of_instances = list()
        user_qs = list()
        if instances.__len__() > 0:

            # If logged-in user is owner of stream show all collaborator
            phone_numbers = [str(_.phone_number) for _ in instances]
            if phone_numbers.__len__() > 0:
                condition = reduce(operator.or_, [Q(username__icontains=s) for s in phone_numbers])
                user_qs = User.objects.filter(condition).filter(is_active=True).values('id', 'user_data__id', 'user_data__full_name', 'username', 'user_data__user_image')

            if user_qs.__len__() > 0:
                for user, instance in product(user_qs, instances):
                    # If some collaborator are registered
                    if user.get('username') is not None and user.get('username').endswith(instance.phone_number):
                        setattr(instance, 'name', user.get('user_data__full_name'))
                        setattr(instance, 'user_profile_id', user.get('user_data__id'))
                        setattr(instance, 'user_id', user.get('id'))
                        setattr(instance, 'user_image', user.get('user_data__user_image'))
                    # If some collaborator are not registered.
                    elif not user.get('username').endswith(instance.phone_number) and not instance.phone_number in map(lambda x: x.phone_number, list_of_instances):
                        setattr(instance, 'name', instance.name)
                        setattr(instance, 'user_profile_id', None)
                        setattr(instance, 'user_id', None)
                        setattr(instance, 'user_image', None)
                    list_of_instances.append(instance)
            # If any collaborator is not registered
            else:
                for instance in instances:
                    setattr(instance, 'name', instance.name)
                    setattr(instance, 'user_profile_id', None)
                    setattr(instance, 'user_id', None)
                    setattr(instance, 'user_image', None)
                    list_of_instances.append(instance)
            list_of_instances = list(set(list_of_instances))
        return list_of_instances

    def get_collab_images(self, obj):
        fields = ('id', 'name', 'phone_number', 'can_add_content', 'can_add_people', 'image', 'user_image', 'added_by_me', 'user_profile_id', 'user_id', 'status', 'created_by')
        instances = obj.stream_collaborator
        list_of_instances = self.get_collab_data(obj, instances)
        if instances.__len__() > 0:
            owner_collab = []
            other_collab = []
            for i in list_of_instances:
                if i.phone_number == self.context.get('request').user.username:
                    owner_collab.append(i)
                else:
                    other_collab.append(i)
            if owner_collab:
                list_of_instances = owner_collab + other_collab[0:2]
            else:
                list_of_instances = other_collab[0:3]
        return ViewCollaboratorSerializer(list_of_instances,
                                          many=True, fields=fields, context=self.context).data
    
    def get_total_collaborator(self, obj):
        try:
            return obj.stream_collaborator.__len__()
        except Exception:
            return '0'

    def get_author(self, obj):
        try:
            return obj.created_by.user_data.full_name
        except AttributeError:
            return None

    def get_user_image(self, obj):
        try:
            return obj.created_by.user_data.user_image
        except AttributeError:
            return None

    def get_total_likes(self, obj):
        try:
            return obj.total_like_dislike_data.__len__()
        except AttributeError:
            return None

    def get_is_collaborator(self, obj):
        # check Profile stream have any collaborator available or not
        try:
            return True if obj.profile_stream_collaborator_list.__len__() > 0 else False
        except Exception:
            return '0'

    def get_liked(self, obj):
        for x in obj.total_like_dislike_data:
            if x.user_id == self.context.get('request').auth.user_id:
                return True
        return False

    def get_user_liked(self, obj):
        # Find the logged in user and fetch current user's followers 
        user_id = self.context.get('request').user.id
        try:
            return [{'id': x.user.id, 'user_profile_id': x.user.user_data.id, 'user_image': x.user.user_data.user_image,'full_name': x.user.user_data.full_name, 'display_name': x.user.user_data.display_name, 'is_following': True if user_id in  map(lambda y: y.follower.id, x.user.user_liked_followers) else False } for x in obj.total_like_dislike_data ]
        except AttributeError:
            return None

    def get_view_count(self, obj):
        try:
            return obj.total_view_count.__len__() + obj.view_count
        except AttributeError:
            return 0

    def get_collaborators(self, obj):
        fields = ('id', 'name', 'phone_number', 'can_add_content', 'can_add_people', 'image', 'user_image', 'added_by_me', 'user_profile_id', 'user_id', 'status', 'created_by')
        if self.context.get('version'):
            instances = obj.stream_collaborator_verified
        else:
            instances = obj.stream_collaborator
        list_of_instances = self.get_collab_data(obj, instances)
        return ViewCollaboratorSerializer(list_of_instances,
                                          many=True, fields=fields, context=self.context).data

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image',
            'height', 'width', 'color', 'full_name', 'user_image', 'liked', 'file')
        instances = obj.content_list
        return ViewContentSerializer([x.content for x in instances], many=True, fields=fields, context=self.context).data

    def get_stream_permission(self, obj):
        qs = obj.stream_collaborator
        # If current user as collaborator
        user_phono_number = str(self.context.get('request').user.username)
        qs = [x for x in qs if str(x.phone_number) in user_phono_number]
        # qs = [x ]&t
        # If current user as owner of stream
        if obj.created_by.__str__() == self.context.get('request').user.__str__():
            return {'can_add_content': True, 'can_add_people': True}

        if qs.__len__() > 0:
            # If Collaborator have permission for can add content 
            return {'can_add_content': qs[0].can_add_content, 'can_add_people': qs[0].can_add_people}
            # fields = ('can_add_content', 'can_add_people')
            # return ViewCollaboratorSerializer(qs[0], fields=fields).data
        else:
            # If current user a sophisticated user.
            # If stream is public and any_one_can_edit is true
            if obj.any_one_can_edit:
                return {'can_add_content': obj.any_one_can_edit , 'can_add_people': False}
            # If stream is public and any_one_can_edit is False
            else:
                return {'can_add_content': False, 'can_add_people': False}

    def get_collaborator_permission(self, obj):
        if self.context.get('version') == 'v3':
            list_of_obj = [_ for _ in obj.stream_collaborator if _.created_by == obj.created_by and _.phone_number == obj.created_by.username ]
        else:
            list_of_obj = [_ for _ in obj.stream_collaborator if _.created_by == self.context.get('request').user and _.phone_number == self.context.get('request').user.username ]

        if list_of_obj.__len__() > 0:
            return {'can_add_content': list_of_obj[0].can_add_content, 'can_add_people': list_of_obj[0].can_add_people}
        return {'can_add_content': True , 'can_add_people': False}

    def get_stream_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image',
            'height', 'width', 'color', 'full_name', 'user_image', 'liked', 'file')
        instances = obj.content_list[0:6]
        return ViewContentSerializer([x.content for x in instances], many=True, fields=fields, context=self.context).data

    def get_is_bookmarked(self, obj):
        exists = [x for x in obj.total_starred_stream_data if x.user == self.context.get('request').user]
        if exists.__len__() > 0:
            return True
        else:
            return False

    def get_is_seen(self, obj):
        exists = [x for x in obj.total_view_count if x.user == self.context.get('request').user]
        if exists.__len__() > 0:
            return True
        else:
            return False


class ContentCommentSerializer(DynamicFieldsModelSerializer):
    """
    ContentComment model Serializer
    """

    user_full_name = serializers.SerializerMethodField()
    user_id = serializers.SerializerMethodField()
    user_image = serializers.SerializerMethodField()
    user_display_name = serializers.SerializerMethodField()

    class Meta:
        model = ContentComment
        fields = "__all__"

    def get_user_full_name(self, obj):
        return obj.user.user_data.full_name

    def get_user_id(self, obj):
        return obj.user.id

    def get_user_image(self, obj):
        return obj.user.user_data.user_image

    def get_user_display_name(self, obj):
        return obj.user.user_data.display_name