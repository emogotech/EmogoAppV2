from rest_framework.response import Response
from django.conf import settings
from django_twilio.client import TwilioRestClient

import random


def custom_render_data(status=None, message=None, response_status=None, token=None, data={}):
    """
    Common method for getting rendering response to user.
    :param status:
    :param message:
    :param response_status:
    :param token:
    :param data:
    :return:
    """
    if isinstance(data, bool):
        """
        This specific condition is written if user want data empty list
        """
        return Response({"status": status, "data": [], "message": message}, status=response_status)

    if len(data) >= 1 or data == []:
        if token:
            response = Response({"status": status, "data": data, "message": message, "token": token},
                                status=response_status)
        else:
            response = Response({"status": status, "data": data, "message": message}, status=response_status)
    else:
        if token:
            response = Response({"status": status, "message": message, "token": token}, status=response_status)
        else:
            response = Response({"status": status, "message": message}, status=response_status)

    if token:
        response['Authorization'] = 'Token ' + token

    return response


def _get_pin(length=5):
    """ Return a numeric PIN with length digits """
    return random.sample(range(10 ** (length - 1), 10 ** length), 1)[0]


def send_otp(phone_number):
    """
    Sending sms to verify user registration
    :param phone_number:
    :return:
    """
    pin = _get_pin()

    client = TwilioRestClient(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    message = client.messages.create(
        body="%s" % pin,
        to=phone_number,
        from_=settings.TWILIO_FROM_NUMBER,
    )

    return pin
