from rest_framework import serializers
from django.contrib.auth.models import User
from emogo.apps.users.models import UserProfile
from rest_framework.validators import UniqueValidator
from emogo.lib.utils import generate_pin


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

    password = serializers.CharField(read_only=True)
    user_name = serializers.CharField()
    phone_number = serializers.CharField(source='username', validators=[UniqueValidator(queryset=User.objects.all())])

    class Meta:
        model = User
        fields = ['email','password','phone_number','user_name']
        extra_kwargs = {'password': {'required': True}}

    def create(self, validated_data):
        """
        :param validated_data:
        :return: Create User and user profile object
        """
        user = User.objects.create(username=validated_data.get('username'))
        user.set_password('123456')
        user.save()
        setattr(self, 'user_pin' ,generate_pin())
        user_profile = UserProfile(full_name=validated_data.get('user_name'),
                                      user=user, otp=self.user_pin)
        user_profile.save()
        return user
