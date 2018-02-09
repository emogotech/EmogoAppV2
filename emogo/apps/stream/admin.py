# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.contrib import admin
from emogo.apps.stream.models import Stream, Content


class StreamAdmin(admin.ModelAdmin):
    model = Stream
    search_fields = ('name',)
    list_display = ['name', 'type', 'featured', 'emogo', 'owner']

    def owner(self, obj):
        return obj.created_by.user_data.full_name


class ContentAdmin(admin.ModelAdmin):
    model = Content

    list_display = ('name', 'type', 'url', 'owner',)

    def name(self, obj):
        return obj.name

    def owner(self, obj):
        return obj.created_by.user_data.full_name


admin.site.register(Stream, StreamAdmin)
admin.site.register(Content, ContentAdmin)
# Register your models here.
