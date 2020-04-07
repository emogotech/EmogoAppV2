from rest_framework.fields import ListField, DictField
from rest_framework.utils import html
import collections
from django.utils import six
from django.utils.translation import ugettext_lazy as _
from rest_framework import serializers


class CustomListField(ListField):
    def to_internal_value(self, data):
        """
        List of dicts of native values <- List of dicts of primitive datatypes.
        """
        if html.is_html_input(data):
            data = html.parse_html_list(data)

        if not isinstance(data, list):
            self.fail('not_a_list', input_type=type(data).__name__)

        if isinstance(data, type('')) or isinstance(data, collections.Mapping) or not hasattr(data, '__iter__'):
            self.fail('not_a_list', input_type=type(data).__name__)

        if not self.allow_empty and len(data) == 0:
            self.fail('empty')
        return [self.child.run_validation(item) for item in data]


class CustomDictField(DictField):
    child = serializers.CharField()

    def __init__(self, *args, **kwargs):
        # setattr(self,'keys',kwargs.get('has_key',False))
        self.default_error_messages.update({
            'does_not_have_key': _('Expected dictionary does not have key:"{input_type}".')
        })
        self.keys = False
        if kwargs.get('has_key') is not None:
            self.keys = kwargs.pop('has_key')

        if kwargs.get('child') is not None:
            self.child = kwargs.pop('child')
        super(DictField, self).__init__(*args, **kwargs)

    def to_internal_value(self, data):
        """
        Dicts of native values <- Dicts of primitive datatypes.
        """
        if html.is_html_input(data):
            data = html.parse_html_dict(data)
        if not isinstance(data, dict):
            self.fail('not_a_dict', input_type=type(data).__name__)

        if self.keys:
            for key in self.keys:
                if str(key) not in list(data.keys()):
                    self.fail('does_not_have_key', input_type=key)
        return {
            six.text_type(key): self.child.run_validation(value)
            for key, value in list(data.items())
        }
