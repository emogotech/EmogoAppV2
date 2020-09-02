from channels.auth import AuthMiddlewareStack
# from rest_framework.authtoken.models import Token
from emogo.apps.users.models import Token
from django.contrib.auth.models import AnonymousUser


class TokenAuthMiddleware:
    """
    Token authorization middleware.
    """

    def __init__(self, inner):
        self.inner = inner

    # def __call__(self, scope):
    #     headers = dict(scope['headers'])
    #     if 'authorization' in headers:
    #         try:
    #             token_name, token_key = headers[b'authorization'].decode().split()
    #             if token_name == 'Token' or token_name == 'token':
    #                 user = Token.objects.select_related(
    #                     "user").only("user").get(key=token).user
    #                 scope['user'] = user
    #             else:
    #                 scope['auth_error'] = "Authentication credentials were not provided."
    #         except Token.DoesNotExist:
    #             scope['auth_error'] = "Invalid token."
    #     else:
    #         scope['auth_error'] = "Authentication credentials were not provided."
    #     return self.inner(scope)

    def __call__(self, scope):
        try:
            token = scope["query_string"].decode().split("token=")[1]
            try:
                user = Token.objects.select_related(
                        "user").only("user").get(key=token).user
                scope['user'] = user
            except:
                scope['auth_error'] = "Invalid Token."
        except:
            scope['auth_error'] = "Authentication credentials were not provided."
        return self.inner(scope)

TokenAuthMiddlewareStack = lambda inner: TokenAuthMiddleware(
    AuthMiddlewareStack(inner))