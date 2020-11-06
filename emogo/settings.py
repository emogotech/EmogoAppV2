"""
Django settings for emogo project.

Generated by 'django-admin startproject' using Django 1.11.7.

For more information on this file, see
https://docs.djangoproject.com/en/1.11/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.11/ref/settings/
"""

import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.11/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'd^6nmg0*yi#6ita0%gpakjft0np#4p!bu*)7!5&zp*$wt!xs86'

# SECURITY WARNING: don't run with debug turned on in production!


ALLOWED_HOSTS = ['*']
import logging
import watchtower
from boto3.session import Session
import watchtower

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'emogo.apps.users',
    'emogo.apps.stream',
    'emogo.apps.collaborator',
    # 'django_twilio',
    'rest_framework',
    # 'rest_framework.authtoken',
    'django_filters',
    # 'twilio-python',
    'autofixture',
    'branchio',
    'emogo.apps.notification',
    'health_check',
    'drf_yasg',
    'channels',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'emogo.lib.common_middleware.stream_view_middleware.UpdateStreamViewCount',
]

ROOT_URLCONF = 'emogo.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'emogo.wsgi.application'
ASGI_APPLICATION = "emogo.routing.application"

# Password validation
# https://docs.djangoproject.com/en/1.11/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
# https://docs.djangoproject.com/en/1.11/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.11/howto/static-files/

STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATIC_URL = '/static/'

# global status for application
STATUSES = (
    ('Active', 'Active'),
    ('Inactive', 'Inactive'),
    ('Deleted', 'Deleted'),
    ('Unverified', 'Unverified'),
)

REST_FRAMEWORK = {
    'DEFAULT_PARSER_CLASSES': (
        'rest_framework.parsers.JSONParser',
        # 'rest_framework.parsers.FormParser',
        # 'rest_framework.parsers.MultiPartParser',
    ),
    'EXCEPTION_HANDLER': 'emogo.lib.helpers.utils.custom_exception_handler',
    'DEFAULT_PAGINATION_CLASS': 'emogo.lib.default_paginations.pagination.CustomPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': ('django_filters.rest_framework.DjangoFilterBackend',)

}

DEFAULT_PASSWORD = '123456'

# Twilio Credential
TWILIO_ACCOUNT_SID = 'AC470ab177bba5b96f4c1af3d3d29b8975'
TWILIO_AUTH_TOKEN = '1491edbec65ec8a99f72b6c0bee54aca'
TWILIO_FROM_NUMBER = '+13392090249'

branch_key = 'key_live_joqR74nNwWBqb7BRWJV00fhmvAaUXijJ'
branch_secret = 'secret_live_hZTVlPYzyHR5OZ2fHEoQkPsWnJvuDx4u'
DATA_BRANCH_IOS_URL = 'https://itunes.apple.com/us/app/emogo/id1341315142?ls=1&mt=8'

# S3 bucket credential
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_BUCKET_NAME = os.getenv('AWS_BUCKET_NAME')
AWS_REGION_NAME = os.getenv('AWS_REGION_NAME')

# Max file upload size on server
DATA_UPLOAD_MAX_MEMORY_SIZE = 20971520

# boto3_session = Session(
#   aws_access_key_id=AWS_ACCESS_KEY_ID,
#   aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
#   region_name=AWS_REGION_NAME
# )

# LOGGING = {
#     'version': 1,
#     'disable_existing_loggers': False,
#     'formatters': {
#         'simple': {
#             'format': u"%(asctime)s [%(levelname)-8s] %(message)s",
#             'datefmt': "%Y-%m-%d %H:%M:%S"
#         },
#         'aws': {
#             'format': u"%(asctime)s [%(levelname)-8s] %(message)s",
#             'datefmt': "%Y-%m-%d %H:%M:%S"
#         },
#     },
#     'handlers': {
#         'console': {
#             'class': 'logging.StreamHandler',
#             'formatter': 'simple',
#         },
#         'debug_handlers': {
#             'level': 'INFO',
#             'class': 'watchtower.CloudWatchLogHandler',
#             'boto3_session': boto3_session,
#             'log_group': 'Cloudwatch-Emogo-Group-Name',
#             'stream_name': os.getenv('CONSOLE_FILENAME'),
#             'formatter': 'aws',
#         },
#         'email_log_handlers': {
#             'level': 'INFO',
#             'class': 'watchtower.CloudWatchLogHandler',
#             'boto3_session': boto3_session,
#             'log_group': 'Cloudwatch-Emogo-Group-Name',
#             'stream_name': os.getenv('LOGGER_FILENAME'),
#             'formatter': 'aws',
#         },
#     },
#     'loggers': {
#         'django': {
#             'level': 'INFO',
#             'handlers': ['debug_handlers'],
#             'propagate': True,
#         },
#         'email_log': {
#             'level': 'INFO',
#             'handlers': ['email_log_handlers'],
#             'propagate': False,
#         },
#     },
# }


SWAGGER_SETTINGS = {

    'SECURITY_DEFINITIONS': {
        'api_key': {
            'type': 'apiKey',
            'in': 'header',
            'name': 'Authorization'
        }
    },  # setting to pass token in header
    'USE_SESSION_AUTH': False,
    # set to True if session based authentication needed
    'JSON_EDITOR': True,
    'api_path': 'api/',
    'api_version': 'v0',

    "is_authenticated": False,  # Set to True to enforce user authentication,
    "is_superuser": False,  # Set to True to enforce admin only access
    'unauthenticated_user': 'django.contrib.auth.models.AnonymousUser',
    # unauthenticated user will be shown as Anonymous user in swagger UI.
}

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [('127.0.0.1', 6379)],
        },
    },
}

# CELERY STUFF
BROKER_URL = 'redis://localhost:6379'
CELERY_RESULT_BACKEND = 'redis://localhost:6379'
CELERY_ACCEPT_CONTENT = ['application/json']
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
# CELERY_TIMEZONE = 'Africa/Nairobi'

# Get Local Settings
NOTIFICATION_PEM_FILE = os.getenv('NOTIFICATION_PEM_FILE')
IS_SANDBOX = True
NOTIFICATION_PEM_ROOT = os.path.join(BASE_DIR, NOTIFICATION_PEM_FILE)
# print(NOTIFICATION_PEM_ROOT)

DEBUG = os.getenv('DEBUG')

DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DBENGINE'),
        'NAME': os.environ.get('DBNAME'),
        'USER': os.environ.get('DBUSER'),
        'PASSWORD': os.environ.get('DBPASSWORD'),
        'HOST': os.environ.get('DBHOST'),
        'PORT': os.environ.get('DBPORT'),
    }
}

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
