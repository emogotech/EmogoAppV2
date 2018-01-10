from django.conf.urls import url
from emogo.apps.stream import views

urlpatterns = [
    url(r'^stream/(?P<pk>[0-9]+)/$', views.StreamAPI.as_view()),
    url(r'^stream/$', views.StreamAPI.as_view()),
    url('^stream', views.StreamAPI.as_view()),
    # The API is created because developer unable to get link type content
    url(r'^content/link_type/$', views.LinkTypeContentAPI.as_view()),
    url(r'^content/(?P<pk>[0-9]+)/$', views.ContentAPI.as_view()),
    url(r'^content/$', views.ContentAPI.as_view()),
    url(r'^move_content_to_stream/$', views.MoveContentToStream.as_view()),
    url(r'^extremist_report/$', views.ExtremistReportAPI.as_view()),
]
