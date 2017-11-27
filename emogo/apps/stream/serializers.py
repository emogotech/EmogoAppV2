from emogo.lib.common_serializers.custom_serializer_fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.custom_serializers import DynamicFieldsModelSerializer
from models import Stream


class StreamSerializer(DynamicFieldsModelSerializer):
    """
    Stream model Serializer
    """
    # collaborator = CustomListField(child=CustomDictField())
    # content = CustomListField(child=CustomDictField())
    # collaborator_permission = CustomDictField()

    class Meta:
        model = Stream
        fields = '__all__'
