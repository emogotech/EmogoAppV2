from rest_framework import serializers
from django.contrib.auth.models import User
from emogo.apps.users.models import UserProfile
from rest_framework.validators import UniqueValidator
from emogo.lib.utils import generate_pin
from emogo.constants import messages
from rest_framework.authtoken.models import Token

class DynamicFieldsModelSerializer(serializers.ModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` argument that
    controls which fields should be displayed.
    """

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        fields = kwargs.pop('fields', None)

        # Instantiate the superclass normally
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)

        if fields:
            # Drop any fields that are not specified in the `fields` argument.
            allowed = set(fields)
            existing = set(self.fields.keys())
            for field_name in existing - allowed:
                self.fields.pop(field_name)


class UserSerializer(DynamicFieldsModelSerializer):
    """
    User model Serializer
    """
    password = serializers.CharField(read_only=True)
    user_name = serializers.CharField()
    phone_number = serializers.CharField(source='username', validators=[UniqueValidator(queryset=User.objects.all())])

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
        user.set_password('123456')
        user.save()
        setattr(self, 'user_pin', generate_pin())
        user_profile = UserProfile(full_name=validated_data.get('user_name'), user=user, otp=self.user_pin)
        user_profile.save()
        return user


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

    def save(self):
        self.instance.otp = None
        self.instance.save(update_fields=['otp'])
        Token.objects.create(user=self.instance.user)
        return self.instance


class UserLoginSerializer(UserSerializer):
    """
    User OTP serializer inherits : UserProfileSerializer
    """
    phone_number = serializers.CharField(source='username')

