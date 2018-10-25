# # -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render
from django.contrib.auth.models import User
from django.db.models import Q

from rest_framework.generics import UpdateAPIView, DestroyAPIView
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from emogo.lib.helpers.utils import custom_render_response
from emogo.apps.collaborator.models import Collaborator
from emogo.apps.stream.models import Stream
from emogo.apps.notification.views import NotificationAPI
from django.utils.decorators import method_decorator


# # Create your views here.
class CollaboratorInvitationAPI(UpdateAPIView, DestroyAPIView):
    """
    Accpet  CRUD API
    """
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
        if kwargs['invites'] == 'accept' and request.method == 'PATCH' :
            stream = Stream.objects.get(id = request.data.get('stream'))
            collab = Collaborator.objects.filter( stream = stream ).filter( Q(id =  kwargs.get('pk'), phone_number = request.user.username) | Q(phone_number = stream.created_by.username, created_by=stream.created_by) )
            collab.update(status = 'Active')        
            if kwargs['version']:
                NotificationAPI().send_notification(self.request.user, stream.created_by, 'joined', stream)
            # # To return accpted
            return custom_render_response(status_code=status.HTTP_200_OK)
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

            stream = Stream.objects.get(id = request.data.get('stream'))
            Collaborator.objects.filter( stream = stream ).filter( Q(id =  kwargs.get('pk'), phone_number = request.user.username)).update(status = 'Deleted') 
            collab = Collaborator.objects.filter( stream = stream ).filter(status = 'Active')

            if kwargs['version'] and collab.__len__() == 1:
                collab.filter(phone_number = stream.created_by.username, created_by=stream.created_by).update(status = 'Unverified')
                NotificationAPI().create_notification(self.request.user, stream.created_by, 'decline', stream)
            return custom_render_response(status_code=status.HTTP_200_OK, data=None)
        else:
            return custom_render_response(status_code=status.HTTP_404_NOT_FOUND)
