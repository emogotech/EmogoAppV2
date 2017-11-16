# -*- coding: utf-8 -*-
from __future__ import unicode_literals

# django rest
from rest_framework.views import APIView
from django.db import transaction
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

#constants
from emogo.constants import messages

#util method
from emogo.lib.utils import custom_render_data, send_otp

#Models
from django.contrib.auth.models import User
from emogo.apps.users.models import UserProfile

#serializer
from emogo.apps.users.serializers import UserSerializer

class Signup(APIView):
    """
    user can register his detail and able to login in system.
    """
    def post(self, request):
        if 'phone_number' in request.data:
            request.data['username'] =  request.data['phone_number']
        try:
            with transaction.atomic():
                if not User.objects.filter(username=request.data['phone_number']).exists():
                    user_serializer = UserSerializer(data=request.data)
                    pin = send_otp(request.data['phone_number'])
                    user_serializer.create(request.data, pin)
                    message, status_code, response_status = messages.MSG_REGISTRATION_CONFIRMATION, "200", status.HTTP_201_CREATED
                else :
                    message, status_code, response_status, pin = messages.MSG_PHONE_NUMBER_EXISTS, "400", status.HTTP_200_OK, ""
                return custom_render_data(status_code, message, response_status, data={"otp":pin})
        except :
            message, status_code, response_status = messages.MSG_DATA_VALIDATION_ERROR, "400", status.HTTP_200_OK
            return custom_render_data(status_code, message, response_status, token=None)

class VerifyRegistration(APIView) :
    """
    This API is use to give access to signup user.
    User can directly login to the application.
    """
    def post(self, request):
        code = request.data['otp']
        data = {}
        token = None
        try:
            if code :
                if UserProfile.objects.filter(otp = code).exists() :
                    userData = UserProfile.objects.get(otp=code)

                    #  setting user data
                    data["phone_number"] = userData.user.username
                    data["user_name"] = userData.full_name
                    data ["image"] = userData.user_image if userData.user_image else ""
                    data["user_id"] = userData.user.id

                    token = Token.objects.create(user=userData.user)

                    userData.otp = None
                    userData.save()

                    message, status_code, response_status = messages.MSG_USER_VERIFICATION, "200", status.HTTP_200_OK
                else :
                    message, status_code, response_status = messages.MSG_USER_NOT_VERIFIED, "400", status.HTTP_400_BAD_REQUEST
            else:
                message, status_code, response_status = messages.MSG_REQUEST_DATA_EMPTY, "400", status.HTTP_400_BAD_REQUEST

            if token :
                return custom_render_data(status_code, message, response_status, token=token.key, data={"user":data})

            return custom_render_data(status_code, message, response_status)
        except :
            message, status_code, response_status = messages.MSG_USER_VERIFICATION_ERROR, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_data(status_code, message, response_status)

class Login(APIView):
    """
    Normal user can login to the system and can get access token according to his cred.
    """
    def post(self,request):
        phone_number = request.data['phone_number']
        password = '123456'

        data = {}
        token = None
        try:
            if phone_number and password:
                user = authenticate(request, username=phone_number, password=password)
                if user is not None:
                    userData = UserProfile.objects.filter(user = user, status='Active')
                    if len(userData):
                        if userData[0].otp is None:
                            if Token.objects.filter(user=user).exists():
                                user.auth_token.delete()
                            token = Token.objects.create(user=user)

                            # setting user data
                            data["phone_number"] = user.username
                            data["user_name"] = userData[0].full_name
                            data["image"] = userData[0].user_image if userData.user_image else ""
                            data["user_id"] = user.id

                            message, status_code, response_status = messages.MSG_LOGIN_SUCCESS, "200", status.HTTP_200_OK
                        else:
                            message, status_code, response_status = messages.MSG_VERIFY_EMAIL, "400", status.HTTP_200_OK
                    else:
                        message, status_code, response_status = messages.MSG_ACCOUNT_DEACTIVATED, "400", status.HTTP_200_OK
                else:
                    message, status_code, response_status = messages.MSG_INVALID_PHONE_NUMBER, "400", status.HTTP_200_OK
            else:
                message, status_code, response_status = messages.MSG_REQUEST_DATA_EMPTY, "400", status.HTTP_200_OK
            if token:
                return custom_render_data(status_code, message, response_status, token=token.key, data={"user":data})

            return custom_render_data(status_code, message, response_status)
        except :
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_IN, "400", status.HTTP_200_OK
            return custom_render_data(status_code, message, response_status)


class Logout(APIView):
    """
    Use to logout from the system
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request):
        try :
            # simply delete the token to force a login
            request.user.auth_token.delete()
            message, status_code, response_status = messages.MSG_LOGOUT_SUCCESS, "200", status.HTTP_200_OK
            return custom_render_data(status_code, message, response_status)
        except :
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_OUT, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_data(status_code, message, response_status)