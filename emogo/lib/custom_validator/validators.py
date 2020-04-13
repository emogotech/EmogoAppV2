from rest_framework.validators import UniqueValidator ,qs_exists, qs_filter


class CustomUniqueValidator(UniqueValidator):
    """
    Validator that corresponds to `unique=True` on a model field.

    Should be applied to an individual field on the serializer.
    """
    def filter_queryset(self, value, queryset):
        """
        Filter the queryset to all instances matching the given attribute.
        """
        filter_kwargs = {'%s__%s' % (self.field_name, self.lookup): value}
        filter_kwargs.update({'user_data__otp__isnull': True})
        return qs_filter(queryset, **filter_kwargs)