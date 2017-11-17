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
from emogo.apps.users.models import UserProfile
# serializer
from emogo.apps.users.serializers import UserSerializer, UserOtpSerializer, UserDetailSerializer, UserLoginSerializer, UserResendOtpSerializer


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
    User login API
    """

    def post(self, request):
        serializer = UserLoginSerializer(data=request.data, fields=('phone_number',))
        password = '123456'  # Todo The hard code password is set to maintain django authentication.
        if serializer.is_valid(raise_exception=True):
            user = authenticate(request, username=request.data.get('phone_number'), password=password)
            if user:
                user.auth_token.delete()
                try:
                    user_profile = UserProfile.objects.get(user=user)
                    Token.objects.create(user=user)
                    serializer = UserDetailSerializer(instance=user_profile)
                    return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)
                except UserProfile.DoesNotExist:
                    return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST,
                                                  data={'phone_number': messages.MSG_INVALID_PHONE_NUMBER})
            return custom_render_response(status_code=status.HTTP_400_BAD_REQUEST,
                                          data={'phone_number': messages.MSG_INVALID_PHONE_NUMBER})


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

class UniqueUserName(APIView):
    """
    User unique name API
    """
    def post(self, request):
        serializer = UserSerializer(data=request.data, fields=('user_name',))
        if serializer.is_valid(raise_exception=True):
            return custom_render_response(status_code=status.HTTP_200_OK, data=serializer.data)

class ResendOTP(APIView):
    """
    This API for sending an OTP.
    """

    def post(self, request):
        serializer = UserResendOtpSerializer(data=request.data, fields=('phone_number', ))
        if serializer.is_valid(raise_exception=True):
            with transaction.atomic():
                user_pin = serializer.resend_otp(request.data)
                return custom_render_response(status_code=status.HTTP_200_OK, data={"otp": user_pin})