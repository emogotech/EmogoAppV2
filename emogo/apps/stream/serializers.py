from emogo.lib.common_serializers.fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from models import Stream, Content, ExtremistReport, StreamContent, LikeDislikeStream, LikeDislikeContent, StreamUserViewStatus
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.collaborator.serializers import ViewCollaboratorSerializer
from rest_framework import serializers
import itertools
from django.db import transaction
from emogo.constants import messages
import datetime
from django.core.urlresolvers import resolve
from copy import deepcopy
from django.contrib.auth.models import User
import operator
from django.db.models import Q, Count
from itertools import product
from emogo.apps.notification.views import NotificationAPI



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
                        'type': {'required': True, 'allow_blank': False, 'allow_null': False}
                        # 'image': {'required': True, 'allow_blank': False, 'allow_null': False}
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
        # Get variable any one can true
        any_one_can_edit = self.validated_data.get('any_one_can_edit')
            
        # If any_one_can_edit variable is True, Set default stream's type is Public
        if any_one_can_edit:
            self.validated_data['type'] = 'Public'

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

        #3  Update the status of  all collaborator is Inactive When Stream is Global otherwise Collaborator Status is Active
        if self.context['version']:
            collaborator_list = self.instance.collaborator_list.exclude(status='Unverified')    
        else:
            collaborator_list = self.instance.collaborator_list.all()    
        if collaborator_list.__len__ > 0 :
            stream_type = self.validated_data.get('type')
            if stream_type == 'Public':
                # When Stream is (Public -> Global) and (Private -> Global), (Global -> Public) 
                status = 'Inactive' if any_one_can_edit else 'Active'
            else:
                # When Stream is (Global  -> Private), so collaboratopr status is Active 
                status = 'Active'
            collaborator_list.update(status=status)

        # 4. Set have_some_update is true, when user edit the stream..
        self.instance.have_some_update = True
        self.instance.save()
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
        :Call owner stream for adding Stream's Owner as collaborators in collaborators list ..
        :return: Add Stream collaborators.
        """

        collaborator_list = self.initial_data.get('collaborator')
        self.owner_collaborator(stream, collaborator_list)
        collaborators = map(self.save_collaborator, collaborator_list,
                            itertools.repeat(stream, collaborator_list.__len__()))
        
        if stream.collaborator_list.count() == 1:
            if  stream.collaborator_list.all()[0].created_by == self.context.get('request').user and \
                stream.collaborator_list.all()[0].phone_number == self.context.get('request').user.username:
                self.instance.collaborator_list.filter().delete()
        else:
            return collaborators

    def save_collaborator(self, data, stream):
        """
        :param data: Collaborator data
        :param stream: Stream object
        :return: Save Collaborator  object
        """
        if str(data.get('phone_number')) not in str(self.context.get('request').user) :
            if data.get('status') and self.context['version']:
                status = data.get('status')
            else:
                status = 'Active'
            collaborator, created = Collaborator.objects.get_or_create(
                phone_number=data.get('phone_number'),
                stream=stream
            )
            collaborator.name = data.get('name')
            collaborator.can_add_content = self.initial_data.get('collaborator_permission').get('can_add_content')
            collaborator.can_add_people = self.initial_data.get('collaborator_permission').get('can_add_people')
            collaborator.created_by = self.context.get('request').user
            collaborator.status = status
            collaborator.save()
            to_user = User.objects.filter(username = collaborator.phone_number )
            if collaborator.status == "Unverified" and self.context['version'] and  to_user.__len__() > 0 and data.get('new_add'):
                NotificationAPI().send_notification(self.context.get('request').user, to_user[0],  'collaborator_confirmation', stream)
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
            width=self.validated_data.get('width', 300),
            color = self.validated_data.get('color')
        )
        stream.save()
        # Update any_one_can_edit flag is type is Public
        if stream.type == 'Public':
            stream.any_one_can_edit = self.validated_data.get('any_one_can_edit', False)
            stream.save()
        return stream

    def owner_collaborator(self, stream, data):
        # Adding and update the streams as collaborator..
        # Check Owner is present or stream have any collabrators or not.
        user_qs = User.objects.filter(id = self.context.get('request').user.id).values('user_data__full_name', 'username')
        if self.context['version']:
            username_list =  {str(d['phone_number']): d['status'] for d in data}
            if user_qs[0].get('username') in username_list:
                status = str(username_list[user_qs[0].get('username')])
            else:
                status = 'Unverified'
        else:
            status = 'Active'
        if stream.collaborator_list.filter().__len__() < 1 :
            
            collaborator, created = Collaborator.objects.get_or_create(
                phone_number=user_qs[0].get('username'),
                stream=stream
            )
            collaborator.name = user_qs[0].get('user_data__full_name')
            collaborator.can_add_content = True
            collaborator.can_add_people = True
            collaborator.created_by = self.context.get('request').user
            collaborator.status = status
            collaborator.save()
            return collaborator


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
    liked = serializers.SerializerMethodField()
    user_image = serializers.SerializerMethodField()
    is_collaborator = serializers.SerializerMethodField()
    stream_contents = serializers.SerializerMethodField()

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

    def get_user_image(self, obj):
        try:
            return obj.created_by.user_data.user_image
        except AttributeError:
            return None

    def get_total_likes(self, obj):
        try:
            return obj.total_like_dislike_data.__len__()
        except AttributeError:
            return None

    def get_is_collaborator(self, obj):
        # check Profile stream have any collaborator available or not
        try:
            return True if obj.profile_stream_collaborator_list.__len__() > 0 else False
        except Exception:
            return '0'

    def get_liked(self, obj):
        for x in obj.total_like_dislike_data:
            if x.user_id == self.context.get('request').auth.user_id:
                return True
        return False

    def get_user_liked(self, obj):
        # Find the logged in user and fetch current user's followers 
        user_id = self.context.get('request').user.id
        try:
            return [{'id': x.user.id, 'user_profile_id': x.user.user_data.id, 'user_image': x.user.user_data.user_image,'full_name': x.user.user_data.full_name, 'display_name': x.user.user_data.display_name, 'is_following': True if user_id in  map(lambda y: y.follower.id, x.user.user_liked_followers) else False } for x in obj.total_like_dislike_data ]
        except AttributeError:
            return None

    def get_view_count(self, obj):
        try:
            return obj.total_view_count.__len__() + obj.view_count
        except AttributeError:
            return 0

    def get_collaborators(self, obj):
        fields = ('id', 'name', 'phone_number', 'can_add_content', 'can_add_people', 'image', 'user_image', 'added_by_me', 'user_profile_id', 'user_id', 'status')
        list_of_instances = list()
        user_qs = list()
        if self.context['version']:
            instances = obj.stream_collaborator_verified
        else:
            instances = obj.stream_collaborator

        if instances.__len__() > 0:

            # If logged-in user is owner of stream show all collaborator
            current_url = resolve(self.context.get('request').path_info).url_name

            # If user as owner or want to get all collaborator list
            if current_url == 'stream_collaborator' or obj.created_by == self.context.get('request').user:
                phone_numbers = [str(_.phone_number) for _ in instances]
                if phone_numbers.__len__() > 0:
                    condition = reduce(operator.or_, [Q(username__icontains=s) for s in phone_numbers])
                    user_qs = User.objects.filter(condition).filter(is_active=True).values('id', 'user_data__id', 'user_data__full_name', 'username', 'user_data__user_image')
            # else Show collaborator created by logged in user.
            else:
                phone_numbers = [str(_.phone_number) for _ in instances]
                if phone_numbers.__len__() > 0:
                    condition = reduce(operator.or_, [Q(username__icontains=s) for s in phone_numbers])
                    user_qs = User.objects.filter(condition).filter(is_active=True).values('id', 'user_data__id', 'user_data__full_name', 'username', 'user_data__user_image')

            if user_qs.__len__() > 0:
                for user, instance in product(user_qs, instances):
                    # print(user.get('username'), instance.phone_number)
                    # If some collaborator are registered
                    if user.get('username') is not None and user.get('username').endswith(instance.phone_number):
                        setattr(instance, 'name', user.get('user_data__full_name'))
                        setattr(instance, 'user_profile_id', user.get('user_data__id'))
                        setattr(instance, 'user_id', user.get('id'))
                        setattr(instance, 'user_image', user.get('user_data__user_image'))
                    # If some collaborator are not registered.
                    elif not user.get('username').endswith(instance.phone_number) and not instance.phone_number in map(lambda x: x.phone_number, list_of_instances):
                        setattr(instance, 'name', instance.name)
                        setattr(instance, 'user_profile_id', None)
                        setattr(instance, 'user_id', None)
                        setattr(instance, 'user_image', None)
                    list_of_instances.append(instance)
            # If any collaborator is not registered
            else:
                for instance in instances:
                    setattr(instance, 'name', instance.name)
                    setattr(instance, 'user_profile_id', None)
                    setattr(instance, 'user_id', None)
                    setattr(instance, 'user_image', None)
                    list_of_instances.append(instance)
            list_of_instances = list(set(list_of_instances))
        return ViewCollaboratorSerializer(list_of_instances,
                                          many=True, fields=fields, context=self.context).data

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image', 'height', 'width', 'color',
                  'full_name', 'user_image', 'liked')
        instances = obj.content_list
        return ViewContentSerializer([x.content for x in instances], many=True, fields=fields, context=self.context).data

    def get_stream_permission(self, obj):
        qs = obj.stream_collaborator
        # If current user as collaborator
        user_phono_number = str(self.context.get('request').user.username)
        qs = [x for x in qs if str(x.phone_number) in user_phono_number]
        # qs = [x ]&t
        # If current user as owner of stream
        if obj.created_by.__str__() == self.context.get('request').user.__str__():
            return {'can_add_content': True, 'can_add_people': True}

        if qs.__len__() > 0:
            # If Collaborator have permission for can add content 
            return {'can_add_content': qs[0].can_add_content, 'can_add_people': qs[0].can_add_people}
            # fields = ('can_add_content', 'can_add_people')
            # return ViewCollaboratorSerializer(qs[0], fields=fields).data
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

    def get_stream_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image', 'height', 'width', 'color',
                  'full_name', 'user_image', 'liked')
        instances = obj.content_list[0:6]
        return ViewContentSerializer([x.content for x in instances], many=True, fields=fields, context=self.context).data


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
    liked = serializers.SerializerMethodField()

    def get_user_image(self, obj):
        return obj.created_by.user_data.user_image

    def get_full_name(self, obj):
        return obj.created_by.user_data.full_name

    def get_created_by(self, obj):
        return obj.created_by.user_data.id

    def get_liked(self, obj):
        if obj.content_liked_user.__len__() > 0:
            for x in obj.content_liked_user:
                if self.context.get('request').auth.user_id == x.user_id:
                    return True
        return False


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

        # Set True in have_some_update field, When user move content to stream
        stream.have_some_update = True
        stream.save()
        if self.context['version']:
            collab_list = stream.collaborator_list.filter(status= 'Active')
            for collab in collab_list.exclude(phone_number = self.context.get('request').user.username):
                to_user = User.objects.filter(username = collab.phone_number)
                if to_user.__len__() > 0:
                    content_ids = [ x.id for x in self.initial_data['contents']]
                    NotificationAPI().send_notification(self.context.get('request').user, to_user[0], 'add_content', stream, None, self.initial_data['contents'].count(), str(content_ids))
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
        fields = ['my_order', 'order', 'id']
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
    total_liked = serializers.SerializerMethodField()
    user_liked = serializers.SerializerMethodField()

    class Meta:
        model = LikeDislikeStream
        fields = ['user', 'stream', 'status', 'total_liked', 'user_liked']
        extra_kwargs = {'status': {'required': True, 'allow_null': False}}

    def liked(self, obj):
        try:
            stream = obj.get('stream') 
        except:
            stream = obj
        return LikeDislikeStream.objects.filter(status=1, stream=stream)

    def get_total_liked(self, obj):
        return self.liked(obj).aggregate(total_liked=Count('id')).get('total_liked',0)
   
    def get_user_liked(self, obj):
        # Find the logged in user and fetch current user's followers 
        try:
            return [{'id': x.user.id, 'user_profile_id': x.user.user_data.id, 'user_image': x.user.user_data.user_image,'full_name': x.user.user_data.full_name, 'display_name': x.user.user_data.display_name, 'is_following': True if x.user.id in  self.context.get('followers') else False } for x in self.liked(obj) ]
        except AttributeError:
            return None

    def create(self, validated_data):
        obj, created = LikeDislikeStream.objects.update_or_create(
            stream=self.validated_data.get('stream'), user=self.context.get('request').user,
            defaults={'status': self.validated_data.get('status')},
        )
        return obj


class ContentLikeDislikeSerializer(DynamicFieldsModelSerializer):
    """
    Stream like dislike serializer class
    """
    user = serializers.CharField(read_only=True)
    total_liked = serializers.SerializerMethodField()

    class Meta:
        model = LikeDislikeContent
        fields = ['user', 'content', 'status', 'total_liked']
        extra_kwargs = {'status': {'required': True, 'allow_null': False}}

    def get_total_liked(self, obj):
        return LikeDislikeContent.objects.filter(status=1, content=obj.get('content')).aggregate(total_liked=Count('id')).get('total_liked',0)

    def create(self, validated_data):
        obj, created = LikeDislikeContent.objects.update_or_create(
            content=self.validated_data.get('content'), user=self.context.get('request').user,
            defaults={'status': self.validated_data.get('status')},
        )
        return obj


class StreamUserViewStatusSerializer(DynamicFieldsModelSerializer):
    """
    Stream user view status API.
    """
    total_view_count = serializers.SerializerMethodField()
    user = serializers.CharField(read_only=True)

    class Meta:
        model = StreamUserViewStatus
        fields = '__all__'
        extra_kwargs = {'stream': {'required': True}}

    def get_total_view_count(self, obj):
        new_view_count = StreamUserViewStatus.objects.filter(stream=obj.get('stream')).aggregate(total_view_count=Count('id')).get('total_view_count', 0)
        return new_view_count + obj.get('stream').view_count

    def create(self, validated_data):
        instance = StreamUserViewStatus.objects.create(stream=self.validated_data.get('stream'), user=self.context.get('request').auth.user)
        instance.save()
        return instance