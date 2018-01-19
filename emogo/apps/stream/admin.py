# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib import admin
from emogo.apps.stream.models import Stream, Content


class StreamAdmin(admin.ModelAdmin):
    model = Stream
    search_fields = ('name',)
    list_display = ['name', 'type',  'featured', 'emogo', 'created_by']


class ContentAdmin(admin.ModelAdmin):
    model = Content
    list_display = ['get_name', 'type','url' ,'created_by']

    def get_name(self, obj):
        return obj.name

admin.site.register(Stream, StreamAdmin)
admin.site.register(Content, ContentAdmin)
# Register your models here.
