import re

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.authtoken.models import Token
from emogo import settings
from emogo.apps.users.models import UserProfile
from emogo.constants import messages
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from emogo.lib.custom_validator.validators import CustomUniqueValidator
from emogo.apps.stream.serializers import ViewStreamSerializer, ViewContentSerializer

from emogo.lib.helpers.utils import generate_pin, send_otp


class UserSerializer(DynamicFieldsModelSerializer):
    """
    User model Serializer
    """

    password = serializers.CharField(read_only=True)
    user_name = serializers.CharField()
    phone_number = serializers.CharField(source='username', validators=[CustomUniqueValidator(queryset=User.objects.all(), message='Phone number already exists.')])

    class Meta:
        model = User
        fields = ['email', 'password', 'phone_number', 'user_name']
        extra_kwargs = {'password': {'required': True}}

    def create(self, validated_data):
        """
        :param validated_data:
        :return: Create User and user profile object
        """

        # The code is run while user was not verified but try to sign-up with different user_name or phone number
        # 1. While user request with same user_name and different phone number
        #sent_otp = send_otp(validated_data.get('username')) # Todo Uncomment this code before move to stage server
        sent_otp = 12345
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
        user.set_password(settings.DEFAULT_PASSWORD)
        user.save()
        if created:
            user_profile = UserProfile(full_name=validated_data.get('user_name'), user=user, otp=self.user_pin)
            user_profile.save()
        else:
            user.user_data.full_name = validated_data.get('user_name')
            user.user_data.otp = self.user_pin
            user.user_data.save()

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

    class Meta:
        model = UserProfile
        fields = ['user_profile_id', 'full_name', 'user', 'user_image', 'token', 'user_image', 'user_id', 'phone_number', 'streams', 'contents', 'collaborators']

    def get_token(self, obj):
        if hasattr(obj.user, 'auth_token'):
            return obj.user.auth_token.key
        return None

    def get_phone_number(self, obj):
        return obj.user.username

    def get_streams(self,obj):
        return None

    def get_contents(self,obj):
        return None

    def get_collaborators(self,obj):
        return None

    def save(self, **kwargs):
        self.instance.user.username = self.initial_data.get('phone_number')
        self.instance.user.save()
        return self.instance


class UserDetailSerializer(UserProfileSerializer):
    """
    UserDetail Serializer to show user detail.
    """
    user_image = serializers.URLField(read_only=True)


    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        # Instantiate the superclass normally
        super(UserDetailSerializer, self).__init__(*args, **kwargs)

    def get_streams(self, obj):

        # By default user can see only public stream
        instances = obj.user_streams().filter(type='Public')

        if self.context.get('request') is not None:
            if obj.user.id == self.context.get('request').user.id:
                instances = obj.user_streams()

            # While logged-in user visits another user profile then will club user created streams and
            # streams in which user as collaborators.
            if obj.user.id != self.context.get('request').user.id:
                collaborators_streams = self.context.get('request').user.user_data.user_as_collaborators()
                if collaborators_streams.exists():
                    collaborators_streams = [x.stream for x in collaborators_streams]
                    self_created = [x for x in instances]
                    instances = collaborators_streams + self_created
        return ViewStreamSerializer(instances, many=True, fields=('id', 'name', 'author', 'image')).data

    def get_collaborators(self, obj):
        if self.context.get('request') is not None:
            collaborators_streams = self.context.get('request').user.user_data.user_as_collaborators()
            if collaborators_streams.exists():
                collaborators_streams = [x.stream for x in collaborators_streams]
            return ViewStreamSerializer(collaborators_streams, many=True, fields=('id', 'name', 'author', 'image')).data
        return list()

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
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)

    def save(self):
        self.instance.otp = None
        self.instance.save(update_fields=['otp'])
        Token.objects.create(user=self.instance.user)
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

    def authenticate(self):
        user = authenticate(username=self.validated_data.get('username'), password=settings.DEFAULT_PASSWORD)
        try:
            user_profile = UserProfile.objects.get(user=user)
            if hasattr(user, 'auth_token'):
                user.auth_token.delete()
            token = Token.objects.create(user=user)
            token.save()
        except UserProfile.DoesNotExist:
            raise serializers.ValidationError(messages.MSG_PHONE_NUMBER_NOT_REGISTERED)
        return user_profile


class UserResendOtpSerializer(UserProfileSerializer):
    """
    User OTP serializer inherits : UserProfileSerializer
    """
    phone_number = serializers.CharField()

    def resend_otp(self, validated_data):
        setattr(self, 'user_pin', generate_pin())
        if User.objects.filter(username=validated_data.get('phone_number')).exists():
            user = User.objects.get(username=validated_data.get('phone_number'))
            user_profile = UserProfile.objects.get(user=user)
            user_profile.otp = self.user_pin
            user_profile.save()

        return self.user_pin

    def validate_phone_number(self, value):
        if re.match(r'(^[+0-9]{1,3})*([0-9]{10,11}$)', value):
            return value
        else:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)
