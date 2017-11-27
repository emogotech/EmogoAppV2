from rest_framework.validators import UniqueValidator, qs_filter, qs_exists
from rest_framework.exceptions import ValidationError
from rest_framework.compat import unicode_to_repr
from rest_framework.utils.representation import smart_repr


class CustomUniqueValidator(UniqueValidator):
    pass
