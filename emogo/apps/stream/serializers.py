from emogo.lib.common_serializers.fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from models import Stream, Content
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.collaborator.serializers import ViewCollaboratorSerializer
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
            if isinstance(delete_content, list) and delete_content.__len__() > 0:
                if all(isinstance(item, int) for item in delete_content):
                    qs = Content.actives.filter(id__in=delete_content, streams=self.instance)
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
        content = Content(
            name=data.get('name'),
            url=data.get('url'),
            type=data.get('type'),
            created_by=self.context['request'].user
        )
        content.save()
        content.streams.add(stream)
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
            emogo=self.validated_data.get('emogo', False),
            featured=self.validated_data.get('featured', False),
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
    collaborators = serializers.SerializerMethodField()
    contents = serializers.SerializerMethodField()
    stream_permission = serializers.SerializerMethodField()

    def get_author(self, obj):
        try:
            return obj.created_by.user_data.full_name
        except AttributeError:
            return None

    def get_collaborators(self, obj):
        fields = ('name', 'phone_number', 'can_add_content', 'can_add_people', 'image')
        return ViewCollaboratorSerializer(obj.collaborator_list.filter(status='Active'),
                                          many=True, fields=fields).data

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image')
        return ViewContentSerializer(Content.actives.filter(streams=obj).distinct(), many=True, fields=fields).data

    def get_stream_permission(self, obj):
        qs = obj.collaborator_list.filter(status='Active', phone_number=self.context['request'].user.username)
        if qs.exists():
            fields = ('can_add_content', 'can_add_people')
            return ViewCollaboratorSerializer(qs[0], fields=fields).data
        else:
            if obj.created_by.__str__() == self.context['request'].user.__str__():
                return {'can_add_content': True, 'can_add_people':True}
        return None


class ContentListSerializer(serializers.ListSerializer):
    """
    Content list Serializer
    """
    def create(self, validated_data):
        contents = []
        for item in validated_data:
            item.update({'created_by':self.context['request'].user})
            contents.append(Content(**item))
        return Content.objects.bulk_create(contents)


class ContentSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    # streams = CustomListField(child=serializers.IntegerField())
    url = serializers.URLField()

    class Meta:
        model = Content
        fields = '__all__'
        list_serializer_class = ContentListSerializer
        extra_kwargs = {'name': {'required': True, 'allow_blank': False, 'allow_null': False},
                        'url': {'required': True, 'allow_blank': False, 'allow_null': False},
                        'type': {'required': True, 'allow_blank': False, 'allow_null': False}
                        }


class ContentBulkDeleteSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    # streams = CustomListField(child=serializers.IntegerField())
    content_list = CustomListField(child=serializers.IntegerField(min_value=1), min_length=1)

    class Meta:
        model = Content
        fields = '__all__'


class ViewContentSerializer(ContentSerializer):
    """
    This serializer is used to show Content view section
    """
    pass
    # streams = serializers.SerializerMethodField()
    #
    # def get_stream(self, obj):
    #     try:
    #         return obj.stream.name
    #     except AttributeError:
    #         return None


class MoveContentToStreamSerializer(ContentSerializer):
    """
    Move Content to Stream Serializer
    """
    contents = CustomListField(child=serializers.IntegerField(min_value=1), min_length=1)
    streams = CustomListField(child=serializers.IntegerField(min_value=1), min_length=1)

    class Meta:
        model = Content
        fields = ('contents', 'streams')

    def validate_contents(self, value):
        """
        :param value: request content data.
        :return: Validate contents data.
        """
        contents = set(self.initial_data.get('contents'))
        contents = Content.actives.filter(created_by=self.context.user, id__in=contents)
        if contents.exists():
            self.initial_data['contents'] = contents
        else:
            raise serializers.ValidationError({'contents': messages.MSG_INVALID_ACCESS.format('contents')})
        return value

    def validate_streams(self, value):
        """
        :param value: request streams data
        :return: Validate streams request data
        """
        streams = set(self.initial_data.get('streams'))
        streams = Stream.actives.filter(id__in=streams)
        if streams.exists():
            for stream in streams:
                if stream.created_by != self.context.user :
                    collaborators = stream.collaborator_list.filter(phone_number=self.context.user.username, can_add_content=True)
                    if not collaborators.exists():
                        raise serializers.ValidationError({'streams': messages.MSG_INVALID_ACCESS.format('streams')})
            self.initial_data['streams'] = streams
        else:
            raise serializers.ValidationError({'streams': messages.MSG_INVALID_ACCESS.format('streams')})
        return value

    def save(self, **kwargs):
        """
        :param kwargs: validated data
        :return: save serializer data
        """
        for stream in self.initial_data.get('streams'):
            map(self.add_content_to_stream, self.initial_data.get('contents'),
                                itertools.repeat(stream, self.initial_data.get('contents').__len__()))
        return True

    def add_content_to_stream(self, content, stream):
        """
        :param content: The content object
        :param stream: The stream object
        :return: Function add content to stream
        """
        content.streams.add(stream)
        return self.initial_data['contents']
