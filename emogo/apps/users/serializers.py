import re

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.authtoken.models import Token
from rest_framework.validators import UniqueValidator
from emogo import settings
from emogo.apps.users.models import UserProfile
from emogo.constants import messages
from emogo.lib.common_serializers.custom_serializers import DynamicFieldsModelSerializer
from emogo.lib.helpers.utils import generate_pin


class UserSerializer(DynamicFieldsModelSerializer):
    """
    User model Serializer
    """

    password = serializers.CharField(read_only=True)
    user_name = serializers.CharField()
    phone_number = serializers.CharField(source='username', validators=[UniqueValidator(queryset=User.objects.all(), message='Phone number already exists.')])

    class Meta:
        model = User
        fields = ['email', 'password', 'phone_number', 'user_name']
        extra_kwargs = {'password': {'required': True}}

    def create(self, validated_data):
        """
        :param validated_data:
        :return: Create User and user profile object
        """
        user = User.objects.create(username=validated_data.get('username'))
        user.set_password(settings.DEFAULT_PASSWORD)
        user.save()
        setattr(self, 'user_pin', generate_pin())
        user_profile = UserProfile(full_name=validated_data.get('user_name'), user=user, otp=self.user_pin)
        user_profile.save()
        return user

    def validate_user_name(self, value):
        if UserProfile.objects.filter(full_name__iexact=value, otp__isnull=True).exists():
            raise serializers.ValidationError(messages.MSG_USER_NAME_EXISTS)
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

    class Meta:
        model = UserProfile
        fields = ['full_name', 'user', 'user_image', 'token', 'user_image', 'user_id', 'phone_number']

    def get_token(self, obj):
        if self.instance is not None:
            return self.instance.user.auth_token.key
        return None

    def get_phone_number(self, obj):
        if self.instance is not None:
            return self.instance.user.username
        return None


class UserDetailSerializer(UserProfileSerializer):
    """
    UserDetail Serializer to show user detail.
    """
    pass


class UserOtpSerializer(UserProfileSerializer):
    """
    User OTP serializer inherits : UserProfileSerializer
    """
    otp = serializers.IntegerField(min_value=1)
    phone_number = serializers.CharField(source='user.username')

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        self.Meta.fields.append('otp')
        # self.Meta.fields.append('otp')

        # Instantiate the superclass normally
        super(UserOtpSerializer, self).__init__(*args, **kwargs)

    def validate_otp(self, value):
        try:
            self.instance = UserProfile.objects.get(otp=value, user__username=self.initial_data.get('phone_number'))
        except UserProfile.DoesNotExist:
            raise serializers.ValidationError(messages.MSG_INVALID_OTP_OR_PHONE)
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
            user.auth_token.delete()
            Token.objects.create(user=user)
        except UserProfile.DoesNotExist:
            raise serializers.ValidationError(messages.MSG_INVALID_PHONE_NUMBER)
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
