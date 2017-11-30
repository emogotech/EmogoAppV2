from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from rest_framework import serializers
from models import Collaborator


class CollaboratorSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """

    class Meta:
        model = Collaborator
        fields = '__all__'


class ViewCollaboratorSerializer(CollaboratorSerializer):
    """
    This serializer is used to show Collaborator view section
    """
    stream = serializers.SerializerMethodField()

    def get_stream(self, obj):
        try:
            return obj.stream.name
        except AttributeError:
            return None
