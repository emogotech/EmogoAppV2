from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from rest_framework import serializers
from models import Collaborator
from emogo.apps.users.models import UserProfile
from django.contrib.auth.models import User


class CollaboratorSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    added_by_me = serializers.CharField(source='created_by', read_only=True)
    user_profile_id = serializers.SerializerMethodField()

    class Meta:
        model = Collaborator
        fields = '__all__'

    def get_user_profile_id(self, obj):
        qs = User.objects.filter(is_active=True, username__icontains=str(obj.phone_number))
        if qs.exists():
            return qs[0].user_data.id
        else:
            return None


class ViewCollaboratorSerializer(DynamicFieldsModelSerializer):
    """
    This serializer is used to show Collaborator view section
    """
    stream = serializers.SerializerMethodField()
    added_by_me = serializers.SerializerMethodField()
    user_image = serializers.SerializerMethodField()
    user_profile_id = serializers.SerializerMethodField()
    user_id = serializers.SerializerMethodField()
    name = serializers.SerializerMethodField()

    class Meta:
        model = Collaborator
        fields = '__all__'

    def get_user_info(self, obj):
        return User.objects.filter(is_active=True, username__icontains=str(obj.phone_number))

    def get_added_by_me(self, obj):
        if self.context['request'].user == obj.created_by:
            return True
        else:
            return False

    def get_user_image(self, obj):
        return obj.user_image

    def get_user_profile_id(self, obj):
        return obj.user_profile_id

    def get_name(self, obj):
        return obj.name

    # Get User id 
    def get_user_id(self, obj):
        return obj.user_id