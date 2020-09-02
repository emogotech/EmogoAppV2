# In consumers.py
# from channels import Group
from emogo.apps.users.models import Token
from emogo.apps.stream.models import (
    Stream, ContentComment, Content, StreamContent, CommentAcknowledgement)
from emogo.apps.users.serializers import ContentCommentSerializer
from emogo.apps.users.models import UserProfile
from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from channels.exceptions import DenyConnection
from django.core.exceptions import ObjectDoesNotExist
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from emogo.apps.notification.models import Notification
from emogo.apps.notification.views import NotificationAPI
from django.db.models import Prefetch
from django.http import Http404
from functools import wraps
import datetime
import json
import threading


class CommentConsumer(WebsocketConsumer):

    def check_user_is_authenticate_to_stream(self, stream_id, user):
        try:
            stream = Stream.actives.select_related('created_by').prefetch_related(
                "collaborator_list").get(id=stream_id)
            if stream.type == "Private":
                if stream.created_by != user and not any(True for collb in \
                    stream.collaborator_list.all() if user.username.endswith(
                        collb.phone_number[-10:])):
                    raise Http404
            return stream, True
        except:
            return None, False
            # raise Http404("The Emogo does not exist.")

    def create_group_and_connect(self):
        # Function to create dynamic channel group by stream type
        # from django.db import connection, reset_queries
        # reset_queries()
        # print(len(connection.queries))
        # print(connection.queries)
        stream_id = self.scope['url_route']['kwargs']['stream_id']
        if self.scope['user'].is_anonymous():
            return False
        user = self.scope['user']
        stream, valid_stream = self.check_user_is_authenticate_to_stream(
            stream_id, user)
        if valid_stream:
            print("======", stream.type)
            if stream.created_by == user or any(True for collb in \
                stream.collaborator_list.all() if user.username.endswith(
                    collb.phone_number)):
                    connection_type = "private"
            else:
                connection_type = "public"
            group_name = '{}_{}_comment_group'.format(stream_id, connection_type)
            print("===============", group_name)
            self.room_group_name = group_name
            async_to_sync(self.channel_layer.group_add)(
                self.room_group_name,
                self.channel_name
            )
            return True
        return False

    def connect(self):
        group_create = self.create_group_and_connect()
        if group_create:
            self.accept()
            self.send(text_data="You are now connected with comment socket.")
        else:
            self.close()

    def disconnect(self, close_code):
        if hasattr(self, "room_group_name"):
            async_to_sync(self.channel_layer.group_discard)(
                self.room_group_name,
                self.channel_name
            )

    def receive(self, text_data):
        # self.close()
        # # Or add a custom WebSocket error code!
        # self.close(code=4123)
        data = json.loads(text_data)
        self.comment_actions[data['comment_action']](self, data)

# Connected to websocket.connect
# def ws_connect(message):
#     # Accept the connection
#     print("helloooo")
#     message.reply_channel.send({"accept": True})
#     # Add to the chat group
#     Group("chat").add(message.reply_channel)

# # Connected to websocket.receive
# def ws_receive(message):
#     Group("chat").send({
#         "text": "[user] %s" % message.content['text'],
#     })

# # Connected to websocket.disconnect
# def ws_disconnect(message):
#     Group("chat").discard(message.reply_channel)