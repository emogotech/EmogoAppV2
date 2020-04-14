from rest_framework import pagination
from rest_framework.response import Response


class CustomPagination(pagination.PageNumberPagination):
    """
    Custom pagination class
    """

    def get_paginated_response(self, data=None, status_code=None):
        return Response({
            'next': self.get_next_link(),
            'previous': self.get_previous_link(),
            'count': self.page.paginator.count,
            'status_code': status_code,
            'data': data,
        })
