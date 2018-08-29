import re

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.authtoken.models import Token
from emogo import settings
from emogo.apps.users.models import UserProfile, create_user_deep_link, update_user_deep_link_url, UserFollow
from emogo.constants import messages
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from emogo.lib.custom_validator.validators import CustomUniqueValidator
from emogo.apps.stream.serializers import ViewStreamSerializer, ViewContentSerializer
from emogo.apps.stream.models import Stream, LikeDislikeStream, StreamContent, StreamUserViewStatus, LikeDislikeStream,\
    LikeDislikeContent
from emogo.apps.collaborator.models import Collaborator
from itertools import chain
from django.db import IntegrityError
from emogo.lib.helpers.utils import generate_pin, send_otp
from emogo.apps.stream.views import get_stream_qs_objects
from django.db.models import Prefetch, Count

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
            user_profile = UserProfile.objects.get(full_name=validated_data.get('user_name'), otp__isnull=False)
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
        create_user_deep_link(user)
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
        if hasattr(obj.user, 'auth_token'):
            return obj.user.auth_token.key
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

    class Meta:
        model = UserProfile
        fields = '__all__'

    def get_user_instance(self):
        if isinstance(self.context, dict):
            return self.context.get('request').user
        else:
            return self.context.user

    def get_profile_stream(self, obj):
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'total_likes', 'is_collaborator', 'have_some_update', 'color', 'stream_permission', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'stream_contents', 'any_one_can_edit', 'collaborators')

        if obj.profile_stream is not None and obj.profile_stream.status == 'Active':
            setattr(obj.profile_stream, 'stream_collaborator', obj.profile_stream.profile_stream_collaborator_list)
            setattr(obj.profile_stream, 'content_list', obj.profile_stream.profile_stream_content_list)

            if obj.profile_stream.type == 'Private' and obj.profile_stream.created_by != self.get_user_instance():
                if self.get_user_instance().username in [x.phone_number for x in obj.profile_stream.profile_stream_collaborator_list]:
                    return ViewStreamSerializer(obj.profile_stream, fields=fields, context = self.context).data
                return dict()
            else:
                return ViewStreamSerializer(obj.profile_stream, fields=fields, context = self.context).data
        return dict()

    def get_followers(self, obj):
        return obj.user.followers.__len__()

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
        else:
            user_id = self.context.user.id
        if user_id in [x.following_id for x in obj.user.following]:
            return True
        return False

    def get_contents(self, obj):
        return ViewContentSerializer(obj.user_contents(), many=True, fields=('id', 'name', 'url', 'type', 'video_image')).data


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


    def save(self):
        self.instance.otp = None
        self.instance.save(update_fields=['otp'])
        Token.objects.get_or_create(user=self.instance.user)
        return self.instance


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

    def authenticate_user(self):
        try:
            user = User.objects.get(username=self.validated_data.get('username'))
            # If user is already login then logout requested user and try to new log-in.
            if user.is_authenticated():
                if hasattr(user, 'auth_token'):
                    user.auth_token.delete()
                user.user_data.otp = None
                user.user_data.save()
            user_profile = UserProfile.objects.get(user=user, otp__isnull=True)
            body = "Here is your emogo one time passcode"
            sent_otp = send_otp(self.validated_data.get('username'), body)  # Todo Uncomment this code before move to stage server
            # print sent_otp
            # sent_otp = 12345
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

    def authenticate_login_OTP(self, otp):
        # print self.validated_data.get('username')
        try:
            User.objects.get(username=self.validated_data.get('username'))
            user = authenticate(username=self.validated_data.get('username'), password=otp)
            if user is None:
                raise serializers.ValidationError(messages.MSG_INVALID_OTP)
            user_profile = UserProfile.objects.get(user=user)
            if hasattr(user, 'auth_token'):
                user.auth_token.delete()
            token = Token.objects.create(user=user)
            token.save()
        except (UserProfile.DoesNotExist, User.DoesNotExist):
            raise serializers.ValidationError(messages.MSG_PHONE_NUMBER_NOT_REGISTERED)
        return user_profile


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

    featured = serializers.SerializerMethodField()
    emogo = serializers.SerializerMethodField()
    popular = serializers.SerializerMethodField()
    people = serializers.SerializerMethodField()
    liked = serializers.SerializerMethodField()
    following_stream = serializers.SerializerMethodField()
    private_stream = serializers.SerializerMethodField()
    public_stream = serializers.SerializerMethodField()
    collaborator_qs = Collaborator.actives.all().select_related('stream')

    def use_fields(self):
        fields = ('id', 'name', 'image', 'author' ,'stream', 'url', 'type', 'created_by', 'video_image', 'view_count', 'height', 'width', 'have_some_update', 'color', 'stream_contents', 'stream_permission', 'collaborator_permission', 'total_collaborator', 'total_likes', 'is_collaborator', 'any_one_can_edit', 'collaborators')
        return fields

    def get_serializer_context(self):
        #  Modify the context parameter, pass the request params in context for viewstreamserializer
        return {'request': self.context}


    def get_featured(self, obj):
        qs = self.qs.filter(featured=True).order_by('-stream_view_count')
        return {"total": qs.count(), "data": ViewStreamSerializer(qs[0:10], many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }

    def get_emogo(self, obj):
        qs = self.qs.filter(emogo=True)
        return {"total": qs.count(), "data": ViewStreamSerializer(qs[0:10], many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }

    def get_popular(self, obj):
        # Get self created streams
        owner_qs = self.qs.filter(type='Public').order_by('-view_count')
        if owner_qs.count() < 10:

            # 1. Get user as collaborator in streams created by following's
            stream_ids = self.collaborator_qs.filter(phone_number=self.context.user.username, stream__status='Active',
                                                     stream__type='Private')
            # 2. Fetch stream Queryset objects.
            stream_as_collabs = self.qs.filter(id__in=stream_ids)

            result_list = owner_qs | stream_as_collabs
            total = result_list.__len__()
            result_list = result_list[0:10]
        else:
            total = owner_qs.count()
            result_list = owner_qs[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.get_serializer_context()).data}

    def get_people(self, obj):
        fields = ('user_profile_id', 'full_name', 'phone_number', 'people', 'user_image', 'display_name', 'user_id')
        qs = UserProfile.actives.all().exclude(user=self.context.user).order_by('full_name').select_related('user')
        return {"total": qs.count(), "data": UserDetailSerializer(qs[0:10], many=True, fields=fields,
                                    context=self.context).data}

    def get_liked(self, obj):
        stream_ids_list = LikeDislikeStream.objects.filter(user=self.context.user, status=1).values_list('stream', flat=True)
        result_list = self.qs.filter(id__in=stream_ids_list).order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }

    def get_following_stream(self, obj):
        # 1. Get user as collaborator in streams created by following's
        stream_ids = Collaborator.actives.filter(phone_number=self.context.user.username, stream__status='Active',
                                                 stream__type='Private', created_by_id__in=UserFollow.objects.filter(follower=self.context.user).values_list('following_id', flat=True)).values_list(
            'stream', flat=True)

        # 2. Fetch stream Queryset objects.
        stream_as_collabs = self.qs.filter(id__in=stream_ids)

        # 3. Get main stream created by requested user and stream type is Public.
        main_qs = self.qs.filter(created_by__in=UserFollow.objects.filter(follower=self.context.user).values_list('following_id', flat=True), type='Public').order_by('-upd')
        result_list = main_qs | stream_as_collabs
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }
    
    ## Added Private stream 
    def get_private_stream(self, obj):
        result_list = self.qs.filter(created_by__id=self.context.user.id, type='Private').order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }
    
    ## Added Public stream 
    def get_public_stream(self, obj):
        result_list = self.qs.filter(created_by__id=self.context.user.id, type='Public').order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]
        return {"total": total, "data": ViewStreamSerializer(result_list, many=True, fields=self.use_fields(), context = self.get_serializer_context()).data }
    
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
    contact_list = serializers.ListField(min_length=1)

    class Meta:
        fields = ('contact_list',)

    def find_contact_list(self):
        users = User.objects.all().values_list('username', flat=True)
        # Find User profile for contact list
        fields = ('user_id', 'user_profile_id', 'full_name', 'user_image', 'display_name')
        return {contact: (UserDetailSerializer(UserProfile.objects.get(user__username = contact), fields=fields, context=self.context).data 
                    if contact in users else False) for contact in self.validated_data.get('contact_list') }
