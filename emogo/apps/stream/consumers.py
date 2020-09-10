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
        # A commnon method for broadcasting a comment by stream type
        group_name = '{}_{}_comment_group'.format(stream_id, comment_type)
        async_to_sync(self.channel_layer.group_send)(
            group_name,
            {
                'type': 'broadcast_comment',
                'comment': comment_data
            }
        )

    def check_user_is_authenticate_to_stream(self, stream_id, user):
        """
        Method will check that the user can access the given stream or not.
        If stream is private then only stream owner and collaborator can
        access the stream.
        """
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
        # Comment method to validate the token
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
        # Common method to check that the content is exist in a stream
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

    def validate_socket_data(func):
        # Validator to check the received msg data is valid or not
        @wraps(func)
        def wrapped(self, *args, **kwargs):
            resp = self.validate_user_content_and_stream(args[0])
            if "exception_data" in resp.keys():
                self.send(text_data=json.dumps(resp['exception_data']))
                return
            return func(self, resp["user"], resp["content"],
                        resp["stream"], *args, **kwargs)
        return wrapped

    @validate_socket_data
    def post_comment(self, user, content, stream, data):
        """Function to create a new comment."""
        if not data.get("text"):
            text_error = {
                "status_code": 400,
                "exception": {"text": ["text is required."]}
            }
            self.send(text_data=json.dumps(text_error))
            return
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
        comment_data = {"status_code": 200, "action_type": "post_comment_broadcast"}
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
        paginator = Paginator(comments_objs, 20)
        try:
            comments = paginator.page(page)
        except PageNotAnInteger:
            comments = paginator.page(1)
        except EmptyPage:
            comments = []
        comment_data = {
            'data': ContentCommentSerializer(
                comments, fields=fields, many=True).data,
            'new_data': comments.has_previous() \
                if comments.__len__() and comments.has_previous() else None,
            'old_data': comments.next_page_number() if comments.__len__() and \
                comments.has_next() else None,
            'count': paginator.count,
            "action_type": "get_comments_of_content"
        }
        self.send(text_data=json.dumps(comment_data))

    @validate_socket_data
    def get_all_comments_of_content(self, user, content, stream, data):
        # Function to all the comments related to stream and content.
        filter_params = {"stream__id": stream.id, "content": content}
        page = data.get('page')
        self.get_comments_by_pagination(page, filter_params)

    def send_comments(self, message):
        self.send(text_data=json.dumps(message))

    @validate_socket_data
    def delete_comment(self, user, content, stream, data):
        # Method to delete paricular comment by comment owner
        if "comment_id" not in data.keys():
            resp_data = {
                "status_code": 400,
                "exception": {"comment_id": ["Comment Id is required."]}
            }
            self.send(text_data=json.dumps(resp_data))
            return
        try:
            comnt = ContentComment.actives.get(id=data["comment_id"], user=user)
            comnt.status = "Deleted"
            comnt.save()
            comment_data = {
                "status_code": 204,
                "action_type": "delete_comment_broadcast"
            }
            comment_data["data"] = {
                "stream": stream.id, "content": content.id,
                "comment": data["comment_id"]
            }
            self.broadcast_by_type(
                comment_data, "private", stream.id)
            if stream.type == "Public":
                self.broadcast_by_type(comment_data, "public", stream.id)
        except:
            resp_data = {"status_code": 404, "exception": "Comment does not exist."}
            self.send(text_data=json.dumps(resp_data))

    @validate_socket_data
    def update_read_status(self, user, content, stream, data):
        # Function to update the last seen, date time for content
        CommentAcknowledgement.objects.update_or_create(
            stream=stream, content=content, user=user,
            defaults={'last_seen':datetime.datetime.now()},
        )
        ack_data = {
            "stream": stream.id, "content": content.id,
            "user_id": user.id, "action_type": "update_read_status_broadcast"
        }
        self.broadcast_by_type(ack_data, "private", stream.id)
        if stream.type == "Public":
            self.broadcast_by_type(ack_data, "public", stream.id)

    @validate_socket_data
    def get_unread_status(self, user, content, stream, data):
        # Function to check is there any unread comment for content
        cmt_seen_data = {
            "stream": stream.id, "content": content.id,
            "user_id": user.id, "action_type": "get_unread_status_resp",
            "unread_comments_count": 0,
            "have_unread_comments": False
        }
        comment_last_seen = CommentAcknowledgement.objects.filter(
            stream=stream, content=content, user=user).only("last_seen")
        comments = ContentComment.actives.filter(
            stream=stream, content=content).exclude(user=user).only("crd")
        if not comment_last_seen:
            if comments.__len__() > 0:
                cmt_seen_data["unread_comments_count"] = comments.__len__()
                cmt_seen_data["have_unread_comments"] = True
        else:
            unread_cmts = comments.filter(
                crd__gt=comment_last_seen[0].last_seen)
            if unread_cmts.__len__() > 0:
                cmt_seen_data["unread_comments_count"] = unread_cmts.__len__()
                cmt_seen_data["have_unread_comments"] = True
        self.send(text_data=json.dumps(cmt_seen_data))

    comment_actions = {
        'post_comment': post_comment,
        'get_all_comments_of_content': get_all_comments_of_content,
        "update_read_status": update_read_status,
        "get_unread_status": get_unread_status,
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
        group_created = self.create_group_and_connect()
        if group_created:
            self.accept()
            self.send(text_data="You are now connected with comment socket.")
        else:
            self.close()

    def disconnect(self, close_code):
        print("Called disconnect. =========")
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

    def broadcast_delete(self, event):
        response = event['response']
        self.send(text_data=json.dumps(response))

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