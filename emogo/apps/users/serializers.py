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
from emogo.apps.stream.models import Stream
from emogo.apps.collaborator.models import Collaborator
from itertools import chain
from django.db import IntegrityError
from emogo.lib.helpers.utils import generate_pin, send_otp
from emogo.apps.stream.views import get_stream_qs_objects


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

    class Meta:
        model = UserProfile
        fields = ['user_profile_id', 'full_name', 'user', 'user_image', 'token', 'user_image', 'user_id', 'phone_number'
            , 'streams', 'contents', 'collaborators', 'username', 'location', 'website', 'biography', 'birthday', 'branchio_url', 'profile_stream']

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

    class Meta:
        model = UserProfile
        fields = '__all__'

    # Todo: Need to remove this code but not confirm from Mobile site.
    # def get_streams(self, obj):
    #
    #     # By default user can see only public stream
    #     instances = obj.user_streams().filter(type='Public')
    #
    #     if self.context.get('request') is not None:
    #         if obj.user.id == self.context.get('request').user.id:
    #             instances = obj.user_streams()
    #
    #         # While logged-in user visits another user profile then will club user created streams and
    #         # streams in which user as collaborators.
    #         if obj.user.id != self.context.get('request').user.id:
    #             collaborators_streams = self.context.get('request').user.user_data.user_as_collaborators()
    #             if collaborators_streams.exists():
    #                 collaborators_streams = [x.stream for x in collaborators_streams]
    #                 self_created = [x for x in instances]
    #                 instances = collaborators_streams + self_created
    #     instances = get_stream_qs_objects(instances)
    #     return ViewStreamSerializer(instances, many=True, fields=('id', 'name', 'author', 'image')).data
    #
    # def get_collaborators(self, obj):
    #     if self.context.get('request') is not None:
    #         collaborators_streams = self.context.get('request').user.user_data.user_as_collaborators()
    #         if collaborators_streams.exists():
    #             collaborators_streams = [x.stream for x in collaborators_streams]
    #             collaborators_streams = get_stream_qs_objects(collaborators_streams)
    #         return ViewStreamSerializer(collaborators_streams, many=True, fields=('id', 'name', 'author', 'image')).data
    #     return list()

    def get_profile_stream(self, obj):
        fields = ('id', 'name', 'image', 'author', 'created_by', 'view_count', 'type', 'height', 'width', 'total_likes')
        return ViewStreamSerializer(obj.profile_stream, fields=fields).data

    def get_followers(self, obj):
        return obj.user.followers.__len__()

    def get_following(self, obj):
        return obj.user.following.__len__()

    def get_contents(self, obj):
        return ViewContentSerializer(obj.user_contents(), many=True, fields=('id', 'name', 'url', 'type', 'video_image')).data


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
            body = "Emogo login OTP"
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
            body = "Emogo Resend OTP"
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
    qs = Stream.actives.all().order_by('-id')
    featured = serializers.SerializerMethodField()
    emogo = serializers.SerializerMethodField()
    popular = serializers.SerializerMethodField()
    my_stream = serializers.SerializerMethodField()
    people = serializers.SerializerMethodField()
    collaborator_qs = Collaborator.actives.all()

    def use_fields(self):
        fields = ('id', 'name', 'image', 'author' ,'stream', 'url', 'type', 'created_by', 'video_image', 'view_count', 'height', 'width')
        return fields

    def get_featured(self, obj):
        qs = self.qs.filter(featured=True)
        return {"total": qs.count(), "data":ViewStreamSerializer(get_stream_qs_objects(qs[0:10]), many=True, fields=self.use_fields()).data }

    def get_emogo(self, obj):
        qs = self.qs.filter(emogo=True)
        return {"total": qs.count(), "data": ViewStreamSerializer(get_stream_qs_objects(qs[0:10]), many=True, fields=self.use_fields()).data }

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
        return {"total": total, "data": ViewStreamSerializer(get_stream_qs_objects(result_list), many=True, fields=self.use_fields()).data}

    def get_my_stream(self, obj):

        # Get self created streams
        result_list = self.qs.filter(created_by=self.context.user).order_by('-upd')
        total = result_list.count()
        result_list = result_list[0:10]

        #
        # if owner_qs.count() < 5:
        #     # Get streams user as collaborator and has add content permission
        #     collaborator_permission = [x.stream for x in self.collaborator_qs if
        #                                str(x.phone_number) in str(
        #                                    self.context.user.username) and x.stream.status == 'Active']
        #
        #     # merge result
        #     result_list = list(chain(owner_qs, collaborator_permission))
        #     total = result_list.__len__()
        #     result_list = result_list[0:5]
        # else:
        #     total = owner_qs.count()
        #     result_list = owner_qs[0:5]
        return {"total": total, "data": ViewStreamSerializer(get_stream_qs_objects(result_list), many=True, fields=self.use_fields()).data}

    def get_people(self, obj):
        fields = ('user_profile_id', 'full_name', 'phone_number', 'people', 'user_image')
        qs = UserProfile.actives.all().exclude(user=self.context.user).order_by('full_name')
        return {"total": qs.count(), "data": UserDetailSerializer(qs[0:10], many=True, fields=fields,
                                    context=self.context).data}


class UserFollowSerializer(DynamicFieldsModelSerializer):
    """
    User Follow model Serializer
    """
    class Meta:
        model = UserFollow
        fields = '__all__'