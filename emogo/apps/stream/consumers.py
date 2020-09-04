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

    def validate_stream_content(self, stream, content_id):
        resp_data = {}
        try:
            if not content_id:
                resp_data["exception_data"] = {
                    "status_code": 400,
                    "exception": {"content": ["Content Id is required."]}
                }
            else:
                resp_data['content'] = StreamContent.objects.select_related(
                    "content").only("content").get(stream=stream,
                    content__id=content_id).content
        except ObjectDoesNotExist as e:
            resp_data["exception_data"] = {
                "status_code": 404,
                "exception": "Content does not exist."
            }
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
        content_data = self.validate_stream_content(
            stream_data['stream'], data.get("content"))
        if "exception_data" in content_data.keys():
            return content_data
        resp_data["content"] = content_data['content']
        return resp_data

    def post_comment(self, data):
        """Function to create a new comment."""
        if not data.get("text"):
            text_error = {
                "status_code": 400,
                "exception": {"text": ["text is required."]}
            }
            self.send(text_data=json.dumps(text_error))
            return
        validate_data = self.validate_user_content_and_stream(data)
        if "exception_data" in validate_data.keys():
            self.send(text_data=json.dumps(validate_data['exception_data']))
            return
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
        fields = ("id", "stream", "content", "text", "crd", 'user_full_name',
            'user_id', 'user_image', 'user_display_name')
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

    def get_comments_by_pagination(self, page, filter_params):
        # Function to return comments by pagination
        # token = self.scope["cookies"]["X-Authorization"]
        # stream_id = filter_params["stream__id"]
        # try:
        #     user = Token.objects.select_related(
        #         "user").only("user").get(key=token).user
        # except:
        #     raise Http404("The user does not exist.")
        # stream = self.check_user_is_authenticate_to_stream(stream_id, user)
        comments_objs = ContentComment.actives.select_related(
            "user__user_data").prefetch_related(
            Prefetch(
                "user__user_data",
                queryset=UserProfile.objects.select_related('user'),
                to_attr="comment_user_data"
            )
        ).filter(**filter_params).order_by("-crd")
        fields = ("id", "stream", "content", "text", "crd", 'user_full_name',
            'user_id', 'user_image', 'user_display_name')
        paginator = Paginator(comments_objs, 10)
        try:
            comments = paginator.page(page)
        except PageNotAnInteger:
            comments = paginator.page(1)
        except EmptyPage:
            comments = []
        comment_data = {
            'data': ContentCommentSerializer(
                comments, fields=fields, many=True).data,
            'previous': comments.has_previous() \
                if comments.__len__() and comments.has_previous() else None,
            'next': comments.next_page_number() if comments.__len__() and \
                comments.has_next() else None,
            'count': paginator.count
        }
        self.send(text_data=json.dumps(comment_data))

    def get_all_comments_of_content(self, data):
        # Function to all the comments related to stream and content.
        # stream_id = self.scope['url_route']['kwargs']['stream_id']
        # try:
        #     stream = Stream.actives.only("id").get(id=stream_id)
        # except:
        #     raise Http404("The Emogo does not exist.")
        # try:
        #     content = StreamContent.objects.select_related(
        #         "content").only("content").get(
        #         stream=stream, content__id=data.get("content")).content
        # except:
        #     raise Http404("Content does not exist.")
        validate_data = self.validate_user_content_and_stream(data)
        if "exception_data" in validate_data.keys():
            self.send(text_data=json.dumps(validate_data['exception_data']))
            return
        content = validate_data["content"]
        stream = validate_data["stream"]
        filter_params = {
            "stream__id": stream.id, "content": content,
            "status": "Active"
        }
        page = data.get('page')
        self.get_comments_by_pagination(page, filter_params)

    def send_comments(self, message):
        self.send(text_data=json.dumps(message))

    def delete_comment(self, data):
        validate_data = self.validate_user_content_and_stream(data)
        if "exception_data" in validate_data.keys():
            self.send(text_data=json.dumps(validate_data['exception_data']))
            return
        if "comment_id" not in data.keys():
            resp_data = {
                "status_code": 400,
                "exception": {"comment_id": ["Comment Id is required."]}
            }
            self.send(text_data=json.dumps(resp_data))
            return
        try:
            user = validate_data['user']
            comnt = ContentComment.objects.get(id=data["comment_id"], user=user)
            comnt.status = "Deleted"
            comnt.save()
            comment_data = {"status_code": 204}
            comment_data["data"] = {
                "stream": validate_data["stream"].id,
                "content": validate_data["content"].id,
                "comment": data["comment_id"]
            }
            self.broadcast_by_type(
                comment_data, "private", validate_data["stream"].id)
            if validate_data["stream"].type == "Public":
                self.broadcast_by_type(
                    comment_data, "public", validate_data["stream"].id)
        except:
            resp_data = {
                "status_code": 404,
                "exception": "Comment does not exist."
            }
            self.send(text_data=json.dumps(resp_data))

    comment_actions = {
        'post_comment': post_comment,
        # 'get_all_comments': get_all_comments,
        'get_all_comments_of_content': get_all_comments_of_content,
        # "update_comment_last_seen_status": update_comment_last_seen_status,
        # "get_comments_seen_status": get_comments_seen_status,
        "delete_comment": delete_comment
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