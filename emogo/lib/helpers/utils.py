from rest_framework.response import Response
from django.conf import settings
import random
from emogo import settings
from rest_framework.views import exception_handler, status
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException
import threading


def custom_exception_handler(exc, context):
    """
    :param exc: The execution string
    :param context: view request contest dict
    :return: DRF custom exception handler
    """
    response = exception_handler(exc, context)

    if response is not None:
        response.data = {}
        errors = []
        for field, value in list(response.data.items()):
            errors.append("{} : {}".format(field, " ".join(value)))

        # response.data['errors'] = errors
        response.data['status_code'] = response.status_code
        if isinstance(exc, ValidationError):
            response.data['exception'] = exc.detail
        else:
            response.data['exception'] = str(exc)
    # else:
    #     #  The Error is handled only in case of 500 Internal server error.
    #     return Response({'exception': str(exc), 'status_code': status.HTTP_500_INTERNAL_SERVER_ERROR})
    return response


def custom_render_response(status_code=None, data=None, token=None):
    """
    :param status:
    :param data: data is response data.
    :return:
    """
    return Response({"status_code": status_code, "data": data})


def generate_pin(length=5):
    """
    :param length:
    :return: Return a numeric PIN with length digits
    """

    return random.sample(list(range(10 ** (length - 1), 10 ** length)), 1)[0]


def generate_and_send_otp(phone_number, body, pin):
    # client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    # try:
    #     client.messages.create(to=phone_number, from_=settings.TWILIO_FROM_NUMBER, body="{0} : {1}".format(body, pin))
    # except TwilioRestException as e:
    #     return None  # Todo : developer return here is None it should return proper error from TwilioRestException class
    pass

def send_otp(phone_number, body):
    """
    :param phone_number:
    :return: Sending sms to verify user registration
    """
    pin = 12345
    # pin = generate_pin()
    # thread = threading.Thread(target=generate_and_send_otp, args=[phone_number, body, pin])
    # thread.start()
    # client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    # try:
    #     client.messages.create(to=phone_number, from_=settings.TWILIO_FROM_NUMBER, body="{0} : {1}".format(body, pin))
    # except TwilioRestException as e:
    #     return None  # Todo : developer return here is None it should return proper error from TwilioRestException class
    return pin
