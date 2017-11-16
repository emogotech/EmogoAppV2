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
# constants
from emogo.constants import messages
# util method
from emogo.lib.utils import custom_render_response, send_otp
# Models
from django.contrib.auth.models import User
from emogo.apps.users.models import UserProfile
# serializer
from emogo.apps.users.serializers import UserSerializer, UserOtpSerializer, UserDetailSerializer


class Signup(APIView):
    """
    User can register his detail and able to login in system.
    """
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                # Todo : For now we have commented send_otp code for development purpose
                # send_otp(request.data.get('phone_number'))
                serializer.create(serializer.validated_data)
                return custom_render_response(status_code=status.HTTP_201_CREATED, data={"otp": serializer.user_pin})


class VerifyRegistration(APIView):
    """
    This API to verify OTP.
    """

    def post(self, request):
        serializer = UserOtpSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                instance = serializer.save()
                serializer = UserDetailSerializer(instance=instance)
                return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)


class Login(APIView):
    """
    Normal user can login to the system and can get access token according to his credential.
    """

    def post(self, request):
        phone_number = request.data['phone_number']
        password = '123456'

        data = {}
        token = None
        try:
            if phone_number and password:
                user = authenticate(request, username=phone_number, password=password)
                if user is not None:
                    userData = UserProfile.objects.filter(user=user, status='Active')
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
                return custom_render_response(status_code, message, response_status, token=token.key, data={"user": data})

            return custom_render_response(status_code, message, response_status)
        except:
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_IN, "400", status.HTTP_200_OK
            return custom_render_response(status_code, message, response_status)


class Logout(APIView):
    """
    Use to logout from the system
    """
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def post(self, request):
        try:
            # simply delete the token to force a login
            request.user.auth_token.delete()
            message, status_code, response_status = messages.MSG_LOGOUT_SUCCESS, "200", status.HTTP_200_OK
            return custom_render_response(status_code, message, response_status)
        except:
            message, status_code, response_status = messages.MSG_ERROR_LOGGING_OUT, "400", status.HTTP_400_BAD_REQUEST
            return custom_render_response(status_code, message, response_status)
