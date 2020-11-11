from django.conf.urls import url
from emogo.apps.notification import views

urlpatterns = [
	url(r'^activity_logs/$', views.ActivityLogAPI.as_view()),
	url(r'^notification/delete/(?P<pk>[0-9]+)/$', views.DeleteNotificationAPI.as_view()),
	url(r'^badge/count/$', views.BadgeCountAPI.as_view()),
	url(r'^decrease/badge/count/$', views.ResetBadgeCountAPI.as_view()),
]
