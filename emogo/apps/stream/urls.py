from django.conf.urls import url
from emogo.apps.stream import views

urlpatterns = [
    url(r'^stream/(?P<pk>[0-9]+)/$', views.StreamAPI.as_view()),
    url(r'^stream/$', views.StreamAPI.as_view()),
]