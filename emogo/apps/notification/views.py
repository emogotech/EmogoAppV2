# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import time
import os

from django.shortcuts import render
from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db.models import Prefetch
from apns import APNs, Frame, Payload

from rest_framework import status
from rest_framework.generics import CreateAPIView, UpdateAPIView, ListAPIView, DestroyAPIView, RetrieveAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

from emogo.apps.notification.serializers import ActivityLogSerializer
from emogo.lib.helpers.utils import custom_render_response
from emogo.apps.notification.models import Notification
from emogo.apps.users.models import UserFollow, UserProfile


# Create your views here.
class NotificationAPI():

    def total_counts(self):
        # Return all open notification counts
        return Notification.objects.filter(is_open=True)

    def create_notification(self, from_user, to_user, type, stream=None, content=None, content_count= None, content_lists=None):
        # Create Notification and return instance 
        obj = Notification.objects.create(
            notification_type=type, from_user=from_user, to_user=to_user, stream=stream, content=content, content_count=content_count,content_lists=content_lists )
        return obj 

    def initialize_notification(self, obj):
        # Initialize and call Notification
        try:
            token_hex = obj.to_user.userdevice_set.all()[0].device_token
            if token_hex != '':
                path = settings.NOTIFICATION_PEM_ROOT
                apns = APNs(use_sandbox=True, cert_file=path, key_file=path)
                msg = self.notification_message(obj)
                payload = Payload(alert=msg, sound="default", badge=self.total_counts().filter(to_user = obj.to_user).count())
                apns.gateway_server.send_notification(token_hex, payload)
        except Exception as e:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST)
    
    def send_notification(self, from_user, to_user, type, stream=None, content=None, content_count=None, content_lists=None):
        # Call create notification metrhod and notify to user
        obj = self.create_notification(from_user, to_user, type, stream, content, content_count, content_lists)
        self.initialize_notification(obj)

    def notification_message(self, obj):
        # Return notification message for all type
        user_name = obj.from_user.user_data.full_name
        if obj.notification_type in ['collaborator_confirmation', 'add_content', 'liked_emogo', 'accepted']:
            second_args = obj.stream.name
        elif obj.notification_type in ['joined', 'decline', 'deleted_stream']:
            second_args = ''
            user_name = obj.stream.name
        elif obj.notification_type in ['liked_content']:
            second_args = obj.content.type
        elif obj.notification_type in ['self']:
            user_name = obj.content_count
            second_args = ''
        else:
            second_args = ''
        return obj.get_notification_type_display().format(user_name, second_args)


class ActivityLogAPI(ListAPIView):
    """
    Activity Log API CRUD API
    """
    serializer_class = ActivityLogSerializer
    queryset = Notification.objects.all().order_by('-upd')
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, version, *args, **kwargs):
            return self.list(request, version, *args, **kwargs)

    def list(self, request, version, *args, **kwargs):
        #  Override serializer class : NotificationSerializer
        self.serializer_class = ActivityLogSerializer
        queryset = Notification.objects.filter(to_user=self.request.user).order_by('-upd')

        #  Customized field list
        page = self.paginate_queryset(self.filter_queryset(queryset))
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(data=serializer.data, status_code=status.HTTP_200_OK)


class DeleteNotificationAPI(DestroyAPIView):
    """ Delete Notification """
    queryset = Notification.objects.all()
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def destroy(self, request, version, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Hard Delete Notification
        """

        instance = self.get_object()
        # Perform delete operation
        self.perform_destroy(instance)
        return custom_render_response(status_code=status.HTTP_200_OK, data=None)

class BadgeCountAPI(ListAPIView):
    """ Badge Count Notification """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get(self, request, version, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Get Total counts 
        """
        badge_counts = NotificationAPI().total_counts().filter(to_user = request.user).count()
        return custom_render_response(status_code=status.HTTP_200_OK, data={'badge_counts':badge_counts})


class ResetBadgeCountAPI(ListAPIView):
    """ Reset Badge Count Notification """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request, version, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Get Total counts 
        """
        queryset = NotificationAPI().total_counts().filter(to_user = self.request.user)
        if not request.data['notification_id'] :
            types = ['collaborator_confirmation', 'joined', 'add_content']
            queryset.exclude(notification_type__in=types).update(is_open = False)
        else:
            queryset.filter(id=request.data['notification_id']).update(is_open = False)
        return BadgeCountAPI().get(self.request, version, *args, **kwargs)
