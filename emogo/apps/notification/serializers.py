import itertools
import datetime
from django.db import transaction
from django.contrib.auth.models import User
from django.db.models import Prefetch
from rest_framework import serializers
from emogo.constants import messages

from emogo.lib.common_serializers.fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from models import Notification
from emogo.apps.stream.models import Content, LikeDislikeContent


class ActivityLogSerializer(DynamicFieldsModelSerializer):
    """
    This serializer is used to show Serializer view section
    """
    sender_user = serializers.SerializerMethodField()
    message = serializers.SerializerMethodField()
    stream = serializers.SerializerMethodField()
    content = serializers.SerializerMethodField()
    content_list = serializers.SerializerMethodField()
    confirmation_status = serializers.SerializerMethodField()
    is_follower  = serializers.SerializerMethodField()
    is_following  = serializers.SerializerMethodField()
    is_click  = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = ['id', 'notification_type', 'message', 'upd',
                  'confirmation_status', 'is_follower', 'is_following', 'sender_user', 'stream', 'content', 'content_list', 'is_click']

    def get_message(self, obj):
        from views import NotificationAPI
        try:
            return NotificationAPI().notification_message(obj)
        except AttributeError:
            return None
   
    def get_is_following(self, obj):
        if obj.notification_type == 'follower':
            if self.context.get('request').user.id in [x.follower_id for x in obj.from_user.who_follows.all() if x]:
                return True
        return False

    def get_is_follower(self, obj):
        if obj.notification_type == 'follower':
            if obj.from_user_id in [x.following_id for x in obj.to_user.who_is_followed.all() if x]:
                return True
        return False

    def get_confirmation_status(self, obj):
        if obj.notification_type == 'collaborator_confirmation':
            collab_list = obj.stream.collaborator_list.filter(phone_number=self.context.get('request').user)
            if collab_list.__len__() > 0:
                return collab_list[0].status

    def get_sender_user(self, obj):
        try:
            return [{'id': obj.from_user.id, 'user_profile_id': obj.from_user.user_data.id, 'user_image': obj.from_user.user_data.user_image, 'full_name': obj.from_user.user_data.full_name, 'display_name': obj.from_user.user_data.display_name}]
        except AttributeError:
            retur

    def get_stream(self, obj):
        fields = ('id', 'name', 'image', 'author', 'created_by', 'stream_permission', 'collaborator_permission', 'type')
        from emogo.apps.stream.serializers import ViewStreamSerializer
        if obj.stream is not None and obj.stream.status == 'Active':
            setattr(obj.stream, 'stream_collaborator', obj.stream.collaborator_list.all())
            return ViewStreamSerializer(obj.stream, fields=fields, context=self.context).data
        return dict()

    def get_content(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image', 'height', 'width', 'color',
                  'full_name', 'user_image') 
        from emogo.apps.stream.serializers import ViewContentSerializer
        if obj.content is not None:
            return ViewContentSerializer(obj.content, fields=fields, context=self.context).data

    def get_content_list(self, obj):
        fields = ('id', 'name', 'url', 'type', 'description', 'created_by', 'video_image', 'height', 'width', 'color',
                  'full_name', 'user_image', 'liked')        
        from emogo.apps.stream.serializers import ViewContentSerializer
        if obj.content_lists is not None:
            queryset = Content.actives.all().select_related('created_by__user_data__user').prefetch_related(
                Prefetch(
                    "content_like_dislike_status",
                    queryset=LikeDislikeContent.objects.filter(status=1),
                    to_attr='content_liked_user'
                )
            ).order_by('order', '-crd')
            instances =  queryset.filter(id__in = eval(obj.content_lists) )
            return ViewContentSerializer([x for x in instances], many=True, fields=fields, context=self.context).data

    def get_is_click(self, obj):
        if obj.notification_type == 'liked_emogo':
            return False if obj.stream.status == 'Inactive' else True
        elif obj.stream.type == 'Private':
            collab_list = obj.stream.collaborator_list.filter(phone_number=self.context.get('request').user, status="Active")
            return True if collab_list.__len__() > 0 else False
        elif obj.stream.type == 'Private':
            return True if obj.stream.created_by == self.context.get('request').user else False
        return True

            
