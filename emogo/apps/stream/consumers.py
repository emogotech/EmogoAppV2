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

    def broadcast_by_type(self, comment_data, comment_type, stream_id):
        group_name = '{}_{}_comment_group'.format(stream_id, comment_type)
        async_to_sync(self.channel_layer.group_send)(
            group_name,
            {
                'type': 'broadcast_comment',
                'comment': comment_data
            }
        )

    def check_user_is_authenticate_to_stream(self, stream_id, user):
        data = {}
        try:
            stream = Stream.actives.select_related(
                'created_by').prefetch_related(
                "collaborator_list").get(id=stream_id)
            if stream.type == "Private":
                if stream.created_by != user and not any(True for collb in \
                    stream.collaborator_list.all() if user.username.endswith(
                        collb.phone_number[-10:])):
                    raise Http404
            data["stream"] = stream
            return data
        except:
            data["exception_data"] = {
                "status_code": 404,
                "exception": "The Emogo does not exist."
            }
            return data

    def validate_token(self, data):
        resp_data = {}
        try:
            token = data["token"]
            try:
                resp_data["user"] = Token.objects.select_related(
                        "user").only("user").get(key=token).user
            except:
                resp_data['auth_error'] = "Invalid Token."
        except:
            resp_data['auth_error'] = "Authentication credentials were not provided."
        return resp_data

    def validate_user_content_and_stream(self, data):
        # Function to validate user, stream and content
        resp_data = {}
        stream_id = self.scope['url_route']['kwargs']['stream_id']
        user_data = self.validate_token(data)
        if "auth_error" in user_data.keys():
            resp_data["exception_data"] = {
                "status_code": 401,
                "exception": user_data["auth_error"]
            }
            return resp_data
        resp_data["user"] = user_data['user']
        stream_data = self.check_user_is_authenticate_to_stream(
            stream_id, user_data['user'])
        if "exception_data" in stream_data.keys():
            return stream_data
        resp_data["stream"] = stream_data['stream']
        try:
            resp_data['content'] = StreamContent.objects.select_related(
                "content").only("content").get(stream=stream_data['stream'],
                content__id=data.get("content")).content
        except ObjectDoesNotExist as e:
            resp_data["exception_data"] = {
                "status_code": 404,
                "exception": "Content does not exist."
            }
        return resp_data

    def post_comment(self, data):
        """Function to create a new comment."""
        validate_data = self.validate_user_content_and_stream(data)
        if "exception_data" in validate_data.keys():
            self.send(text_data=json.dumps(validate_data['exception_data']))
        user = validate_data["user"]
        content = validate_data["content"]
        stream = validate_data["stream"]
        comment = ContentComment.objects.create(stream=stream, content=content,
            user=user, text=data.get("text").strip())
        comment_obj = ContentComment.objects.select_related(
            "user__user_data").prefetch_related(
            Prefetch(
                "user__user_data",
                queryset=UserProfile.objects.select_related('user'),
                to_attr="comment_user_data"
            )
        ).get(id=comment.id)
        fields = ("id", "stream", "content", "text", "crd", "user_data")
        comment_data = {"status_code": 200}
        comment_data["data"] = ContentCommentSerializer(
            instance=comment_obj, fields=fields).data

        # Send notification to emogo owner and content creator
        # thread = threading.Thread(target=self.send_new_comment_notification,
        #     args=([stream, content, user]))
        # thread.start()
        self.broadcast_by_type(comment_data, "private", stream.id)
        if stream.type == "Public":
            self.broadcast_by_type(comment_data, "public", stream.id)

    def broadcast_comment(self, event):
        comment = event['comment']
        self.send(text_data=json.dumps(comment))

    comment_actions = {
        'post_comment': post_comment,
        # 'get_all_comments': get_all_comments,
        # 'get_comments_by_stream_content': get_comments_by_stream_content,
        # "update_comment_last_seen_status": update_comment_last_seen_status,
        # "get_comments_seen_status": get_comments_seen_status
    }

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
        validate_data = self.check_user_is_authenticate_to_stream(
            stream_id, user)
        if "exception_data" not in validate_data.keys():
            stream = validate_data["stream"]
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

    def update_new_comment(self, event):
        comment = event['comment']
        self.send(text_data=json.dumps(comment))

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