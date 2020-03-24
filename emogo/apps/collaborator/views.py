# # -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.models import User
from django.db.models import Q
from django.utils.decorators import method_decorator

from rest_framework.generics import UpdateAPIView, DestroyAPIView, ListAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from emogo.lib.helpers.utils import custom_render_response
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.stream.models import Stream
from emogo.apps.notification.models import Notification
from emogo.apps.notification.views import NotificationAPI
from emogo.apps.notification.serializers import *
from emogo.apps.stream.serializers import ViewStreamSerializer

from emogo.apps.collaborator.serializers import ViewCollaboratorSerializer

# # Create your views here.
class CollaboratorInvitationAPI(UpdateAPIView, DestroyAPIView):
    """
    Accpet  CRUD API
    """
    serializer_class = ActivityLogSerializer
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)
    lookup_field = 'pk'

    # def update(self, request, version, *args, **kwargs):
    def update(self, request, *args, **kwargs):
        """
        :param request: The request data
        :param args: list or tuple data
        :param kwargs: dict param
        :return: Update collab API status.
        """
        if kwargs['invites'] == 'accept' and request.method == 'PATCH':
            stream = Stream.objects.get(id=request.data.get('stream'))
            collab = Collaborator.objects.filter(stream=stream).filter(Q(phone_number=request.user.username) | Q(
                phone_number=stream.created_by.username, created_by=stream.created_by))
            collab.update(status='Active')
            if kwargs['version']:
                obj = Notification.objects.filter(id = request.data.get('notification_id'))
                if obj.__len__() > 0:
                    if not (obj[0].notification_type == 'deleted_collaborator' or obj[0].notification_type == 'deleted_stream' ):
                        obj.update(notification_type = 'joined')
                        NotificationAPI().initialize_notification(obj)
                        NotificationAPI().send_notification(self.request.user, obj[0].from_user, 'accepted', stream)
                    serializer = self.get_serializer(obj[0], context=self.request)
                    return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)
            # To return accpted
        else:
            return custom_render_response(status_code=status.HTTP_404_NOT_FOUND)

    def destroy(self, request, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Soft Delete collaborator and change status deleted
        """
        if kwargs['invites'] == 'decline' and request.method == 'DELETE':

            stream = Stream.objects.get(id=request.data.get('stream'))
            Collaborator.objects.filter(stream=stream, phone_number=request.user.username).update(status='Deleted')
            obj = Notification.objects.filter(id = request.data.get('notification_id'))
            if obj.__len__() > 0:
                if not (obj[0].notification_type == 'deleted_collaborator' or obj[0].notification_type == 'deleted_stream' ):
                    obj[0].delete()
                    declined_obj = NotificationAPI().create_notification(self.request.user, self.request.user, 'decline', stream)

                    # message = 'You declined to join {0}'.format(stream.name)
                    collab = Collaborator.objects.filter(
                        stream=stream).filter(status='Active')

                    if kwargs['version'] and collab.__len__() == 1:
                        collab.filter(phone_number=stream.created_by.username,
                                      created_by=stream.created_by).update(status='Unverified')
                else:
                    declined_obj = obj[0]
            if declined_obj:
                serializer = self.get_serializer(declined_obj, context=self.request)
                return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)
        else:
            return custom_render_response(status_code=status.HTTP_404_NOT_FOUND)


class StreamCollaboratorsAPI(ListAPIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def get_serializer_context(self):
        return {'request': self.request, 'version': self.kwargs['version']}

    def get_paginated_response(self, data, status_code=None):
        """
        Return a paginated style `Response` object for the given output data.
        """
        assert self.paginator is not None
        return self.paginator.get_paginated_response(data, status_code=status_code)

    def get(self, request, version, *args, **kwargs):
            return self.list(request, version, *args, **kwargs)

    def list(self, request, version, stream, *args, **kwargs):
        obj = Stream.actives.get(id = stream)
        self.serializer_class = ViewStreamSerializer
        stream_serializer = self.get_serializer(context=self.get_serializer_context())
        list_of_active_instances = stream_serializer.get_collab_data(obj, obj.collaborator_list.filter(status='Active'))
        list_of_pending_instances = stream_serializer.get_collab_data(obj, obj.collaborator_list.filter(status='Unverified'))

        self.serializer_class = ViewCollaboratorSerializer
        collab_fields = ('id', 'name', 'phone_number', 'can_add_content', 'can_add_people', 'image', 'user_image', 'added_by_me', 'user_profile_id', 'user_id', 'status', 'created_by')
        active_collab_serializer = self.get_serializer(list_of_active_instances, many=True, fields=collab_fields)
        pending_collab_serializer = self.get_serializer(list_of_pending_instances, many=True, fields=collab_fields)
        
        list_of_instances = list_of_active_instances + list_of_pending_instances
        page = self.paginate_queryset(list_of_instances)
        collab_data = {'accepted':active_collab_serializer.data, 'pending':pending_collab_serializer.data}
        data = []
        data.append(collab_data)
        if page is not None and kwargs['pages'] == 'True':
            return self.get_paginated_response(data=data, status_code=status.HTTP_200_OK)
        else:
            return custom_render_response(data=data, status_code=status.HTTP_200_OK)


class CollaboratorDeletionAPI(DestroyAPIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def destroy(self, request, *args, **kwargs):
        """
        :param request:
        :param args:
        :param kwargs:
        :return: Hard Delete collaborator
        """
        from emogo.apps.stream.models import StarredStream
        collaborator = Collaborator.objects.get(id=kwargs.get('pk'))
        stream_id = collaborator.stream.id
        collab_user = User.objects.filter(username__endswith = collaborator.phone_number[-10:])
        if collab_user.__len__():
            noti = Notification.objects.filter(notification_type = 'collaborator_confirmation' , stream = collaborator.stream, from_user = self.request.user, to_user = collab_user[0] )
            if noti.__len__() > 0 :
                noti.update(notification_type = 'deleted_collaborator')
        collaborator.delete()
        if collab_user.__len__() > 0:
            StarredStream.objects.filter(user=collab_user[0], stream_id = stream_id).delete()
        stream = Stream.objects.filter(id =stream_id)
        if stream.__len__() > 0:
            if stream[0].collaborator_list.count() == 1:
                collab = Collaborator.objects.filter(stream=stream[0]).filter(
                    phone_number=stream[0].created_by.username, created_by=stream[0].created_by)
                collab.delete()
        return custom_render_response(status_code=status.HTTP_200_OK)