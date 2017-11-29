from emogo.lib.common_serializers.custom_serializer_fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.custom_serializers import DynamicFieldsModelSerializer
from models import Stream, Content
from emogo.apps.collaborator.models import Collaborator
from rest_framework import serializers
import itertools
from django.db import transaction
from emogo.constants import messages


class StreamSerializer(DynamicFieldsModelSerializer):
    """
    Stream model Serializer
    """
    collaborator = CustomListField(child=CustomDictField(has_key=('name', 'phone_number')), read_only=True)
    content = CustomListField(
        child=CustomDictField(child=serializers.CharField(allow_blank=True), has_key=('name', 'url')), read_only=True)
    collaborator_permission = CustomDictField(child=serializers.BooleanField(), read_only=True)

    delete_collaborator = CustomListField(child=serializers.IntegerField(min_value=1), read_only=True)
    delete_content = serializers.ListField(child=serializers.IntegerField(min_value=1), read_only=True)

    class Meta:
        model = Stream
        fields = '__all__'
        extra_kwargs = {'name': {'required': True, 'allow_blank': False, 'allow_null': False},
                        'type': {'required': True, 'allow_blank': False, 'allow_null': False},
                        'image': {'required': True, 'allow_blank': False, 'allow_null': False}
                        }

    def validate(self, attrs):
        # This code is run only in case of update through the PATCH method:
        delete_content = self.initial_data.get('delete_content')
        delete_collaborator = self.initial_data.get('delete_collaborator')
        # 1. Run validation for delete_content list
        if delete_content is not None:
            if isinstance(delete_content, list) and delete_content.__len__()>0:
                if all(isinstance(item, int) for item in delete_content):
                    qs = Content.actives.filter(id__in=delete_content, stream=self.instance)
                    if qs.exists():
                        attrs['delete_content'] = qs
                else:
                    serializers.ValidationError({'delete_component':messages.MSG_INVALID_LIST.format('Delete component')})

        # 2. Run validation for delete_collaborator list
        if delete_collaborator is not None:
            if isinstance(delete_collaborator, list) and delete_collaborator.__len__() > 0:
                if all(isinstance(item, int) for item in delete_collaborator):
                    qs = Collaborator.actives.filter(id__in=delete_collaborator, stream=self.instance)
                    if qs.exists():
                        attrs['delete_collaborator'] = qs
                else:
                    serializers.ValidationError(
                        {'delete_collaborator': messages.MSG_INVALID_LIST.format('Delete Collaborator')})
        return attrs

    def save(self, **kwargs):
        self.instance = self.update(self.instance, self.validated_data)
        #  1. Delete content
        if self.validated_data.get('delete_content') is not None:
            self.delete_stream_content()

        # 2. Delete Collaborator
        if self.validated_data.get('delete_collaborator') is not None:
            self.delete_stream_collaborator()

        # 3. Create Collaborator
        collaborators = self.initial_data.get('collaborator')
        if collaborators is not None:
            if collaborators.__len__() > 0:
                self.create_collaborator(self.instance)

        # 4. Create Contents
        contents = self.initial_data.get('content')
        if contents is not None:
            if contents.__len__() > 0:
                self.create_content(self.instance)

        return kwargs

    def create(self, validated_data):
        """
        :param validated_data: validate data dict
        :return: Consolidate function to create stream and its attribute.
        """
        try:
            with transaction.atomic():
                stream = self.create_stream()
                if stream:
                    contents = self.initial_data.get('content')
                    collaborators = self.initial_data.get('collaborator')
                    if contents is not None:
                        if contents.__len__() > 0:
                            self.create_content(stream)
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

    def create_content(self, stream):
        """
        :param stream: Stream object
        :return: Add Stream content
        """
        content_list = self.initial_data.get('content')
        contents = map(self.save_content, content_list, itertools.repeat(stream, content_list.__len__()))
        return contents

    def save_content(self, data, stream):
        """
        :param data: content data
        :param stream: Stream object
        :return: Save content  object
        """
        content = Content.objects.create(
            name=data.get('name'),
            url=data.get('url'),
            type=data.get('type'),
            stream=stream,
            created_by=self.context['request'].user
        ).save()
        return content

    def delete_stream_content(self):
        """
        :return: Delete stream component
        """
        self.validated_data.get('delete_content').delete()
        return None

    def delete_stream_collaborator(self):
        """
        :return: Delete stream Collaborator
        """
        self.validated_data.get('delete_collaborator').delete()
        return None

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


class ViewStreamSerializer(StreamSerializer):
    """
    This serializer is used to show Serializer view section
    """
    author = serializers.SerializerMethodField()

    def get_author(self,obj):
        try:
            return obj.created_by.user_data.full_name
        except AttributeError:
            return None