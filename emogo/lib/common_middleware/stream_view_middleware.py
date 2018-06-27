"""
Api middleware module
"""
import logging
from django.utils.deprecation import MiddlewareMixin
from emogo import settings
request_logger = logging.getLogger('api.request.logger')
from emogo.apps.stream.models import StreamUserViewStatus, Stream
from django.db import connection

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
        #     # pass
            if request.resolver_match.view_name == 'view_stream' and request.method =='GET' and request.resolver_match.kwargs.__len__() > 0 and response.status_code==200:
                if response.data.get('data') is not None:
                    # Get stream Id
                    stream_id = response.data.get('data').get('id')
                    # Get stream object by stream id and After viewing this stream, update the have_some_field is false
                    stream = Stream.objects.filter(id=stream_id).update(have_some_update = False)
        #             suvs = StreamUserViewStatus.objects.create(user=request.user, stream_id=stream_id)
        #             suvs.save()
                    # print('Counter Done')
        # if response.status_code == 200:
        #     total_time = 0
        #     for query in connection.queries:
        #         print(query)
        #         query_time = query.get('time')
        #         if query_time is None:
        #             # django-debug-toolbar monkeypatches the connection
        #             # cursor wrapper and adds extra information in each
        #             # item in connection.queries. The query time is stored
        #             # under the key "duration" rather than "time" and is
        #             # in milliseconds, not seconds.
        #             query_time = query.get('duration', 0) / 1000
        #         total_time += float(query_time)
        #
        #     print('%s queries run, total %s seconds' % (len(connection.queries), total_time))
        return response
