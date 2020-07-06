# chat/routing.py
from django.conf.urls import url
from .consumers import CommentConsumer

websocket_comments_urlpatterns = [
    url(r'^ws/comment/(?P<comment_id>[^/]+)/$', CommentConsumer),
]
