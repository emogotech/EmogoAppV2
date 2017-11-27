# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from rest_framework import status
from rest_framework.generics import CreateAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from emogo.lib.helpers.utils import custom_render_response
from models import Stream
from serializers import StreamSerializer


class StreamAPI(CreateAPIView):
    """
    Stream CRUD API
    """
    serializer_class = StreamSerializer
    queryset = Stream.actives.all()
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Create Stream API.
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return custom_render_response(status_code=status.HTTP_201_CREATED)
