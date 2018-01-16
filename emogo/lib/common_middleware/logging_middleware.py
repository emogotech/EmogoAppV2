"""
Api middleware module
"""
import logging
from django.utils.deprecation import MiddlewareMixin
from emogo import settings

request_logger = logging.getLogger('api.request.logger')


class LoggingMiddleware(MiddlewareMixin):
    """
    Provides full logging of requests and responses
    """
    _initial_http_body = None

    def process_request(self, request):
        """
        :param request:
        :return: This requires because for some reasons.
        There is no way to access request.body in the 'process_response' method.
        """
        self._initial_http_body = request.body

    def process_response(self, request, response):
        """
        :param request:
        :param response:
        :return: The function will loges response content
        """

        # This logs are write only when DEBUG IS FALSE
        if not settings.DEBUG:
            if (
                            request.method == "POST" or request.method == "GET" or request.method == "PUT" or request.method == "DELETE") and request.META.get(
                    'CONTENT_TYPE') == 'application/json':
                request_logger.log(logging.DEBUG,
                                   "Method Type: {}, Request URL: {},  body: {}, response code: {}, "
                                   "response "
                                   "content: {}"
                                   .format(request.method, request.get_full_path(), self._initial_http_body,
                                           response.status_code,
                                           response.content), extra={
                        'tags': {
                            'url': request.build_absolute_uri()
                        }
                    })
        return response
