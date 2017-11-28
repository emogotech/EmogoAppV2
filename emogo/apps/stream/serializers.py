from emogo.lib.common_serializers.custom_serializer_fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.custom_serializers import DynamicFieldsModelSerializer
from models import Stream, Content
from emogo.apps.collaborator.models import Collaborator
from rest_framework import serializers
import itertools
from django.db import transaction


class StreamSerializer(DynamicFieldsModelSerializer):
    """
    Stream model Serializer
    """
    collaborator = CustomListField(child=CustomDictField(has_key=('name', 'phone_number')), read_only=True)
    content = CustomListField(
        child=CustomDictField(child=serializers.CharField(allow_blank=True), has_key=('name', 'url')), read_only=True)
    collaborator_permission = CustomDictField(child=serializers.BooleanField(), read_only=True)

    class Meta:
        model = Stream
        fields = '__all__'
        extra_kwargs = {'name': {'required': True}, 'type': {'required': True}, 'image': {'required': True}}

    def create(self, validated_data):
        """
        :param validated_data: validate data dict
        :return: Consolidate function to create strema and its attribute
        """
        try:
            with transaction.atomic():
                stream = self.create_stream()
                if stream:
                    contents = self.initial_data.get('content')
                    collaborators = self.initial_data.get('collaborator')
                    if contents is not None:
                        if contents.__len__() > 0:
                            self.create_component(stream)
                    if collaborators is not None:
                        if collaborators.__len__() > 0:
                            self.create_collaborator(stream)
        except Exception as e:  # If there is an any error will roll back all DB transaction.
            raise e
        return stream

    def create_collaborator(self, stream):
        """
        :param stream: The stream object
        :return: Add Stream collaborators.
        """
        collaborator_list = self.initial_data.get('collaborator')
        collaborators = map(self.save_collaborator, collaborator_list,
                            itertools.repeat(stream, collaborator_list.__len__()))
        return collaborators

    def save_collaborator(self, data, stream):
        """
        :param data: Collaborator data
        :param stream: Stream object
        :return: Save Collaborator  object
        """
        collaborator, created = Collaborator.objects.get_or_create(
            phone_number=data.get('phone_number'),
            stream=stream
        )
        collaborator.name = data.get('name')
        collaborator.can_add_content = self.initial_data.get('collaborator_permission').get('can_add_content')
        collaborator.can_add_people = self.initial_data.get('collaborator_permission').get('can_add_people')
        collaborator.created_by = self.context['request'].user
        collaborator.save()
        return collaborator

    def create_component(self, stream):
        """
        :param stream: Stream object
        :return: Add Stream Component
        """
        content_list = self.initial_data.get('content')
        contents = map(self.save_component, content_list, itertools.repeat(stream, content_list.__len__()))
        return contents

    def save_component(self, data, stream):
        """
        :param data: Component data
        :param stream: Stream object
        :return: Save Component  object
        """
        component = Content.objects.create(
            name=data.get('name'),
            url=data.get('url'),
            type=data.get('type'),
            stream=stream,
            created_by=self.context['request'].user
        ).save()
        return component

    def create_stream(self):
        """
        :return: Create stream object
        """
        stream = Stream.objects.create(
            name=self.validated_data.get('name'),
            description=self.validated_data.get('description'),
            category=self.validated_data.get('category'),
            image=self.validated_data.get('image'),
            type=self.validated_data.get('type'),
            created_by=self.context['request'].user
        )
        stream.save()
        # Update any_one_can_edit flag is type is Public
        if stream.type == 'Public':
            stream.any_one_can_edit = self.validated_data.get('any_one_can_edit', False)
            stream.save()
        return stream
