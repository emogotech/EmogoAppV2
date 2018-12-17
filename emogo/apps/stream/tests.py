# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase

# Create your tests here.

def test_cal_total():
    total = views.cal_total(4,5)
    assert total == 9