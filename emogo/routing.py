# from channels.routing import route
# from emogo.consumers import ws_connect, ws_receive, ws_disconnect

# channel_routing = [
#     route("websocket.connect", ws_connect),
#     route("websocket.receive", ws_receive),
#     route("websocket.disconnect", ws_disconnect),
# ]


# from channels.auth import AuthMiddlewareStack
# from channels.routing import ProtocolTypeRouter, URLRouter
# from emogo.apps.stream import routing

# application = ProtocolTypeRouter({
#     'websocket': AuthMiddlewareStack(
#         URLRouter(
#             routing.websocket_comments_urlpatterns
#         )
#     ),
# })