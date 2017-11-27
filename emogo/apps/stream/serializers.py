from emogo.lib.common_serializers.custom_serializer_fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.custom_serializers import DynamicFieldsModelSerializer
from models import Stream
from rest_framework import serializers


class StreamSerializer(DynamicFieldsModelSerializer):
    """
    Stream model Serializer
    """
    collaborator = CustomListField(child=CustomDictField(has_key=('username', 'phone_number')))
    content = CustomListField(child=CustomDictField(child = serializers.CharField(allow_blank=True), has_key=('name', 'url')))
    collaborator_permission = CustomDictField(child=serializers.BooleanField())

    class Meta:
        model = Stream
        fields = '__all__'
        extra_kwargs = {'name': {'required': True}, 'type':{'required': True}}

    def create(self, validated_data):
        instance = self.create_stream(validated_data)
        return instance

    def create_stream(self):
        stream = Stream.objects.create()
        return stream