# In consumers.py
# from channels import Group
from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
import json


class CommentConsumer(WebsocketConsumer):

    def connect(self):
        # self.room_name = self.scope['url_route']['kwargs']['group_id']
        # self.room_group_name = 'chat_%s' % self.room_name
        async_to_sync(self.channel_layer.group_add)(
            'new_comment',
            self.channel_name
        )
        self.accept()
        self.send(text_data="You are now connected with comment socket.")

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            'new_comment',
            self.channel_name
        )

    def receive(self, text_data):
        pass

    def update_new_comment(self, event):
        comments = event['comments']
        self.send(text_data=json.dumps(comments))

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