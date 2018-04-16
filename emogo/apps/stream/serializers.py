from emogo.lib.common_serializers.fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from models import Stream, Content, ExtremistReport, StreamContent, LikeDislikeStream
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.collaborator.serializers import ViewCollaboratorSerializer
from rest_framework import serializers
import itertools
from django.db import transaction
from emogo.constants import messages
import datetime
from django.core.urlresolvers import resolve
from copy import deepcopy


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

        # 1. Create Collaborator
        collaborators = self.initial_data.get('collaborator')
        if collaborators is not None:
            # If collaborators list is empty then delete existing collaborator.
            # If logged in user is owner of stream can delete all collaborators.
            if self.instance.created_by == self.context.get('request').user:
                self.instance.collaborator_list.filter().delete()
            # Other wise delete only self created collaborators.
            else:
                self.instance.collaborator_list.filter(created_by=self.context.get('request').user).delete()
            if collaborators.__len__() > 0:
                self.create_collaborator(self.instance)

        # 2. Create Contents
        contents = self.initial_data.get('content')
        if contents is not None:
            # If collaborators list is empty then delete existing  Contents.
            self.instance.stream_contents.all().delete()
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
        if str(data.get('phone_number')) not in str(self.context.get('request').user) :
            collaborator, created = Collaborator.objects.get_or_create(
                phone_number=data.get('phone_number'),
                stream=stream
            )
            collaborator.name = data.get('name')
            collaborator.can_add_content = self.initial_data.get('collaborator_permission').get('can_add_content')
            collaborator.can_add_people = self.initial_data.get('collaborator_permission').get('can_add_people')
            collaborator.created_by = self.context.get('request').user
            collaborator.save()
            return collaborator
        return False

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
            created_by=self.context.get('request').user
        )
        content.save()
        # Add content to stream
        StreamContent.objects.get_or_create(content=content, stream=stream)
        return content

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
            created_by=self.context.get('request').user,
            height=self.validated_data.get('height', 300),
            width=self.validated_data.get('width', 300)
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
    collaborator_permission = serializers.SerializerMethodField()
    total_collaborator = serializers.SerializerMethodField()
    view_count = serializers.SerializerMethodField()
    total_likes = serializers.SerializerMethodField()
    user_liked = serializers.SerializerMethodField()

    def get_total_collaborator(self, obj):
        try:
            return obj.stream_collaborator.__len__()
        except Exception:
            return '0'

    def get_author(self, obj):
        try:
            return obj.created_by.user_data.full_name
        except AttributeError:
            return None

    def get_total_likes(self, obj):
        try:
            return obj.total_like_dislike_data.__len__()
        except AttributeError:
            return None

    def get_user_liked(self, obj):
        try:
            return [ { 'id': x.user.user_data.id, 'name': x.user.user_data.id, 'user_image': x.user.user_data.user_image }  for x in obj.total_like_dislike_data ]
        except AttributeError:
            return None

    def get_view_count(self, obj):
        return obj.total_view_count.__len__()

    def get_collaborators(self, obj):
        fields = ('id', 'name', 'phone_number', 'can_add_content', 'can_add_people', 'image', 'user_image', 'added_by_me', 'user_profile_id')

        # If logged-in user is owner of stream show all collaborator
        current_url = resolve(self.context.get('request').path_info).url_name
        # If user as owner or want to get all collaborator list
        if current_url == 'stream_collaborator' or obj.created_by == self.context.get('request').user:
            instances = obj.stream_collaborator
        # else Show collaborator created by logged in user.
        else:
            instances = [_ for _ in obj.stream_collaborator if _.created_by == self.context.get('request').user ]

        return ViewCollaboratorSerializer(instances,
                                          many=True, fields=fields, context=self.context).data

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image', 'height', 'width', 'color',
                  'full_name', 'user_image')
        # instances = Content.actives.filter(streams=obj).distinct().order_by('-id')
        instances = obj.content_list
        return ViewContentSerializer([x.content for x in instances], many=True, fields=fields).data

    def get_stream_permission(self, obj):
        qs = obj.stream_collaborator
        # If current user as collaborator
        user_phono_number = str(self.context.get('request').user.username)
        qs = [x for x in qs if str(x.phone_number) in user_phono_number]
        # qs = [x ]&t
        if qs.__len__() > 0:
            fields = ('can_add_content', 'can_add_people')
            return ViewCollaboratorSerializer(qs[0], fields=fields).data
        else:
            # If current user as owner of stream
            if obj.created_by.__str__() == self.context.get('request').user.__str__():
                return {'can_add_content': True, 'can_add_people': True}
            else:
                # If current user a sophisticated user.
                # If stream is public and any_one_can_edit is true
                if obj.any_one_can_edit:
                    return {'can_add_content': obj.any_one_can_edit , 'can_add_people': False}
                # If stream is public and any_one_can_edit is False
                else:
                    return {'can_add_content': False, 'can_add_people': False}

    def get_collaborator_permission(self, obj):
        list_of_obj = [_ for _ in obj.stream_collaborator if _.created_by == self.context.get('request').user ]
        if list_of_obj.__len__():
            return {'can_add_content': list_of_obj[0].can_add_content, 'can_add_people': list_of_obj[0].can_add_people}
        return {'can_add_content': False , 'can_add_people': False}


class ContentListSerializer(serializers.ListSerializer):
    """
    Content list Serializer
    """

    def create(self, validated_data):
        contents = []
        for item in validated_data:
            item.update({'created_by': self.context.get('request').user})
            contents.append(Content(**item))
        return Content.objects.bulk_create(contents)


class ContentSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    # streams = CustomListField(child=serializers.IntegerField())
    url = serializers.URLField(required=False, allow_blank=True)

    class Meta:
        model = Content
        fields = '__all__'
        list_serializer_class = ContentListSerializer
        extra_kwargs = {'name': {'required': False, 'allow_blank': True, 'allow_null': True},
                        'url': {'required': False, 'allow_blank': True, 'allow_null': True},
                        'type': {'required': True, 'allow_blank': False, 'allow_null': False},
                        'streams': {'required': False, 'allow_null': False}
                        }


class CopyContentSerializer(ContentSerializer):
    """
    Copy content Serializer to copy content instance.
    """
    content_id = serializers.IntegerField(required=True)

    class Meta(ContentSerializer.Meta):
        ContentSerializer.Meta.extra_kwargs['type'].update({'required': False, 'allow_blank': False, 'allow_null': False})

    def copy_content(self):
        old_instance = deepcopy(self.instance)
        old_instance.pk = None
        old_instance.created_by = self.context.user
        new_instance = old_instance.save()
        return new_instance


class ContentBulkDeleteSerializer(DynamicFieldsModelSerializer):
    """
    Collaborator model Serializer
    """
    # streams = CustomListField(child=serializers.IntegerField())
    content_list = CustomListField(child=serializers.IntegerField(min_value=1), min_length=1)

    class Meta:
        model = Content
        fields = ['content_list']


class ViewContentSerializer(ContentSerializer):
    """
    This serializer is used to show Content view section
    """
    user_image = serializers.SerializerMethodField()
    full_name = serializers.SerializerMethodField()
    created_by = serializers.SerializerMethodField()

    def get_user_image(self, obj):
        return obj.created_by.user_data.user_image

    def get_full_name(self, obj):
        return obj.created_by.user_data.full_name

    def get_created_by(self, obj):
        return obj.created_by.user_data.id



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
        contents = Content.actives.filter(id__in=contents)
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
            self.initial_data['streams'] = streams
        else:
            raise serializers.ValidationError({'streams': messages.MSG_INVALID_ACCESS.format('streams')})
        return value

    def save(self, **kwargs):
        """
        :param kwargs: validated data
        :return: save serializer data
        """
        self.initial_data['contents'].update(upd=datetime.datetime.now())
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
        # Create Stream and content
        StreamContent.objects.get_or_create(content=content, stream=stream)
        return self.initial_data['contents']


class ExtremistReportSerializer(DynamicFieldsModelSerializer):
    """
    ExtremistReport model Serializer
    """

    class Meta:
        model = ExtremistReport
        fields = ['user', 'stream', 'content', 'type']
        extra_kwargs = {'user': {'required': False, 'allow_null': True},
                        'stream': {'required': False,  'allow_null': True},
                        'content':  {'required': False, 'allow_null': True},
                        }

    def save(self, **kwargs):
        new_obj = ExtremistReport.objects.create(
            user_id=self.initial_data.get('user'),
            stream_id=self.initial_data.get('stream'),
            content_id=self.initial_data.get('content'),
            type=self.initial_data.get('type'),
            created_by=self.context.get('request').user
        )
        new_obj.save()


class DeleteStreamContentSerializer(DynamicFieldsModelSerializer):
    """
    Delete Stream Content API model Serializer
    """
    content = serializers.ListField(child=serializers.IntegerField(), min_length=1)

    class Meta:
        model = Stream
        fields = '__all__'
        extra_kwargs = {'content': {'required': True, 'allow_blank': False, 'allow_null': False},
                        }

    def delete_content(self):
        self.instance.stream_contents.filter(content__in=self.validated_data.get("content")).delete()
        return True


class ReorderStreamContentSerializer(DynamicFieldsModelSerializer):
    """
    Reorder Stream Content API model Serializer
    """
    content = CustomListField(child=CustomDictField(child=serializers.IntegerField(), has_key=('order', 'id' )))

    class Meta:
        model = StreamContent
        fields = '__all__'
        extra_kwargs = {'content': {'required': True, 'allow_null': False},
                        'stream': {'required': True, 'allow_null': False}
                        }

    def reorder_content(self):
        for instance in self.validated_data.get('content'):
            StreamContent.objects.filter(content=instance.get('id'), stream=self.validated_data.get('stream')).update(order=instance.get('order'))
        return True


class ReorderContentSerializer(DynamicFieldsModelSerializer):
    """
    Reorder Stream Content API model Serializer
    """
    my_order = CustomListField(child=CustomDictField(child=serializers.IntegerField(), has_key=('order', 'id' )))

    class Meta:
        model = Content
        fields = ['my_order','order','id']
        extra_kwargs = {'content': {'required': True, 'allow_null': False}}

    def reorder_content(self):
        for instance in self.validated_data.get('my_order'):
            Content.objects.filter(pk=instance.get('id')).update(order=instance.get('order'))
        return True


class StreamLikeDislikeSerializer(DynamicFieldsModelSerializer):
    """
    Stream like dislike serializer class
    """
    user = serializers.CharField(read_only=True)

    class Meta:
        model = LikeDislikeStream
        fields = ['user', 'stream', 'status']
        extra_kwargs = {'status': {'required': True, 'allow_null': False}}

    def create(self, validated_data):
        obj, created = LikeDislikeStream.objects.update_or_create(
            stream=self.validated_data.get('stream'), user=self.context.get('request').user,
            defaults={'status': self.validated_data.get('status')},
        )
        return obj
