"""
Api middleware module
"""
import logging
from django.utils.deprecation import MiddlewareMixin
from emogo import settings
request_logger = logging.getLogger('api.request.logger')
from emogo.apps.stream.models import StreamUserViewStatus


class UpdateStreamViewCount(MiddlewareMixin):
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
        :return: The function will loges response content.
        """
        if request.resolver_match is not None:
            if request.resolver_match.view_name == 'view_stream' and request.method =='GET':
                data = response.data.get('data')
                if data is not None:
                    stream_id = data.get('id')
                    suvs = StreamUserViewStatus.objects.create(user=request.user, stream_id=stream_id)
                    suvs.save()
                    print('Counter Done')
        return response
