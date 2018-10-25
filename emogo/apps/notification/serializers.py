from emogo.lib.common_serializers.fields import CustomListField, CustomDictField
from emogo.lib.common_serializers.serializers import DynamicFieldsModelSerializer
from models import Notification

from rest_framework import serializers
import itertools
from django.db import transaction
from emogo.constants import messages
import datetime
from django.contrib.auth.models import User


class ActivityLogSerializer(DynamicFieldsModelSerializer):
    """
    This serializer is used to show Serializer view section
    """
    sender_user = serializers.SerializerMethodField()
    message = serializers.SerializerMethodField()
    stream = serializers.SerializerMethodField()
    contents = serializers.SerializerMethodField()
    confirmation_status = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = ['id','notification_type', 'message', 'upd', 'confirmation_status', 'can_delete', 'sender_user', 'stream', 'contents']

    def get_message(self, obj):
        from views import NotificationAPI
        try:
            return NotificationAPI().notification_message(obj)
        except AttributeError:
            return None
    
    def get_confirmation_status(self, obj):
        if obj.notification_type == 'collaborator_confirmation':
                return obj.stream.collaborator_list.get(phone_number = self.context.get('request').user).status
  
    def get_sender_user(self, obj):
        try:
            return [{'id': obj.from_user.id, 'user_profile_id': obj.from_user.user_data.id, 'user_image': obj.from_user.user_data.user_image,'full_name': obj.from_user.user_data.full_name, 'display_name': obj.from_user.user_data.display_name}]
        except AttributeError:
            retur

    def get_stream(self, obj):
        fields = ('id', 'name','image')
        from emogo.apps.stream.serializers import ViewStreamSerializer
        if obj.stream is not None and obj.stream.status == 'Active':
                return ViewStreamSerializer(obj.stream, fields=fields, context = self.context).data
        return dict()

    def get_contents(self, obj):
        fields = ('id', 'name', 'url', 'type', 'video_image')
        from emogo.apps.stream.serializers import ViewContentSerializer
        if obj.content is not None:
            return ViewContentSerializer( obj.content, fields=fields, context=self.context).data
