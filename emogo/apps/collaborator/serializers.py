from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from rest_framework import serializers
from models import Collaborator


class CollaboratorSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    added_by_me = serializers.CharField(source='created_by', read_only=True)

    class Meta:
        model = Collaborator
        fields = '__all__'


class ViewCollaboratorSerializer(CollaboratorSerializer):
    """
    This serializer is used to show Collaborator view section
    """
    stream = serializers.SerializerMethodField()
    added_by_me = serializers.SerializerMethodField()

    def get_added_by_me(self, obj):
        if self.context['request'].user == obj.created_by:
            return True
        else:
            return False