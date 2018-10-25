# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import time
import os

from django.shortcuts import render
from django.conf import settings
from rest_framework import status

from emogo.lib.helpers.utils import custom_render_response
from emogo.apps.notification.models import Notification
from apns import APNs, Frame, Payload


# Create your views here.
class NotificationAPI():

    def create_notification(self, from_user, to_user, type, stream=None, content=None, content_count= None):
        obj = Notification.objects.create(
            notification_type=type, from_user=from_user, to_user=to_user, stream=stream, content=content, content_count=content_count)

    def send_notification(self, from_user, to_user, type, stream=None, content=None, content_count=None):
        self.create_notification(from_user, to_user, type, stream, content)
        try:
            token_hex = obj.to_user.userdevice_set.all()[0].device_token
            if token_hex != '':
                path = settings.NOTIFICATION_PEM_ROOT
                apns = APNs(use_sandbox=True, cert_file=path, key_file=path)
                msg = self.notification_message(obj)
                payload = Payload(alert=msg, sound="default")
                apns.gateway_server.send_notification(token_hex, payload)
        except Exception as e:
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST)

    def notification_message(self, obj):
        user_name = obj.from_user.user_data.full_name
        if obj.notification_type in ['collaborator_confirmation', 'joined', 'add_content', 'liked_emogo', 'decline']:
            second_args = obj.stream.name
        elif obj.notification_type in ['liked_content']:
            second_args = obj.content.type
        elif obj.notification_type in ['self']:
            second_args = obj.content_count
        else:
            second_args = ''
        return obj.get_notification_type_display().format(user_name, second_args)

