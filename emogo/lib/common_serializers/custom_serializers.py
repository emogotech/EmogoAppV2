from rest_framework import serializers
from django.utils.translation import ugettext_lazy as _


class DynamicFieldsModelSerializer(serializers.ModelSerializer):
    """
    A ModelSerializer that takes an additional `fields` argument that
    controls which fields should be displayed.
    """
    # This is default_error_messages dict
    default_error_messages = {
        'required': _('{input} is required.'),
        'null': _('{input} may not be null.'),
        'invalid': _('{input} not a valid string.'),
        'blank': _('{input} may not be blank.'),
        'max_length': _('Ensure {input} has no more than {max_length} characters.'),
        'min_length': _('Ensure {input} has at least {min_length} characters.')
    }

    def __init__(self, *args, **kwargs):
        # Don't pass the 'fields' arg up to the superclass
        fields = kwargs.pop('fields', None)

        # Instantiate the superclass normally
        super(DynamicFieldsModelSerializer, self).__init__(*args, **kwargs)

        if fields:
            # Drop any fields that are not specified in the `fields` argument.
            allowed = set(fields)
            existing = set(self.fields.keys())
            for field_name in existing - allowed:
                self.fields.pop(field_name)

        if self.fields:
            for field_name in set(self.fields.keys()):
                if self.fields[field_name].required:
                    self.fields[field_name].error_messages.update({'required': self.default_error_messages['required'].format(input=self.fields[field_name].label) })
                if hasattr(self.fields[field_name],'allow_blank') and not self.fields[field_name].allow_blank:
                    self.fields[field_name].error_messages.update({'blank': self.default_error_messages[
                        'blank'].format(input=self.fields[field_name].label)})
                if hasattr(self.fields[field_name],'allow_blank') and not self.fields[field_name].allow_null:
                    self.fields[field_name].error_messages.update({'null': self.default_error_messages[
                        'null'].format(input=self.fields[field_name].label)})
                # if hasattr(self.fields[field_name],'allow_blank') and not self.fields[field_name].allow_blank:
                #     self.fields[field_name].error_messages.update({'invalid': self.default_error_messages[
                #         'invalid'].format(input=self.fields[field_name].label)})
