from autofixture.generators import Generator , ChoicesGenerator
from django.db.models.query import QuerySet
from random import randint
import random
import uuid

class CustomInstanceSelector(Generator):
    '''
    Select one or more instances from a queryset.
    '''
    empty_value = []

    def __init__(self, queryset, min_count=None, max_count=None, fallback=None,
        limit_choices_to=None,internal_model=None,internal_model_limits=None ,*args, **kwargs):
        if not isinstance(queryset, QuerySet):
            queryset = queryset._default_manager.all()
        limit_choices_to = limit_choices_to or {}
        self.internal_model_limits = internal_model_limits or {}
        self.queryset = queryset.filter(**limit_choices_to)
        self.fallback = fallback
        self.internal_model = internal_model
        self.min_count = min_count
        self.max_count = max_count
        super(CustomInstanceSelector, self).__init__(*args, **kwargs)

    def generate(self):
        if self.max_count is None:
            try:
                if self.internal_model is not None:
                    # self.internal_model_limits.update({'company_budget_alloc': return_qs})
                    qs = self.internal_model._default_manager.filter(**self.internal_model_limits)
                    return_qs = self.queryset.order_by('?')[0]
                    if qs.exists():
                        exclude_budget_alloc = qs.values_list('company_budget_alloc',flat=True)
                        self.queryset = self.queryset.filter().exclude(id__in=set(exclude_budget_alloc))
                        return_qs = self.queryset.order_by('?')[0]
                        return return_qs
                    else:
                        return return_qs
            except IndexError:
                return self.fallback
        else:
            min_count = self.min_count or 0
            count = random.randint(min_count, self.max_count)
            return_qs = self.queryset.order_by('?')[:count]
            return return_qs


class CustomNameGenerator(Generator):
    """
    Class CustomNameGenerator is custom generator for generate name of Object Like Budget , Campaign, Program and expense as well.
    """
    def __init__(self, name_prefix=None, *args, **kwargs):
        self.name_prefix = name_prefix
        super(CustomNameGenerator, self).__init__(*args, **kwargs)

    def generate(self):
        return self.name_prefix+"- {0}".format(uuid.uuid4().hex[:10].upper())


class PhoneNumberGenerator(Generator):
    """
    Class PhoneNumberGenerator is custom generator for generate US Phone number.
    """
    def __init__(self, country_code=None, *args, **kwargs):
        self.country_code = country_code
        super(PhoneNumberGenerator, self).__init__(*args, **kwargs)

    def generate(self):
        n = '0000000000'
        while '9' in n[3:6] or n[3:6] == '000' or n[6] == n[7] == n[8] == n[9]:
            n = str(random.randint(10 ** 9, 10 ** 10 - 1))
        if self.country_code != '+91':
            return self.country_code+"{0}".format(n[:3]+n[3:6]+n[6:])
        else:
            return self.country_code+"{0}".format(n[:3]+n[3:6]+n[6:])