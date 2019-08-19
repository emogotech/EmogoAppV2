# -*- coding: utf-8 -*-
from __future__ import unicode_literals
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from emogo.apps.users.models import UserProfile

admin.site.unregister(User)


class UserInline(admin.StackedInline):
    model = UserProfile
    fields = ['is_suggested']


class CustomUserAdmin(UserAdmin):
    model = User
    list_display = ('user_name', 'phone_number', 'is_staff', 'is_active', 'is_suggested')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'groups')
    search_fields = ('username', 'user_data__full_name','first_name', 'last_name', 'email')
    inlines = [UserInline]

    def user_name(self, obj):
        return obj.user_data.full_name

    def phone_number(self, obj):
        return obj.username

    def is_suggested(self, obj):
        return obj.user_data.is_suggested

    is_suggested.boolean = True

admin.site.register(User, CustomUserAdmin)
# Register your models here.
