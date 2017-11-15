from rest_framework import serializers
from django.contrib.auth.models import User

from emogo.apps.users.models import UserProfile

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

class UserSerializer(DynamicFieldsModelSerializer,serializers.ModelSerializer):

    password = serializers.CharField(write_only=True)

    def create(self, validated_data, random_code):

        #adding user entry
        user = User.objects.create(
            username=validated_data['phone_number'],
        )
        user.set_password('123456')
        user.save()

        userProfileData = UserProfile(full_name=validated_data['user_name'],
                                      user=user,
                                      otp=random_code)
        userProfileData.save()

        return user

    class Meta:
        model = User
        fields = ['username','email','password']
        extra_kwargs = {'password': {'required': True}}