from django.conf.urls import url
from emogo.apps.stream import views

urlpatterns = [
    url(r'^stream/$', views.StreamAPI.as_view()),
]