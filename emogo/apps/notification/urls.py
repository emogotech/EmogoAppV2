from django.conf.urls import url
from emogo.apps.notification import views

urlpatterns = [
	url(r'^activity_logs/$', views.ActivityLogAPI.as_view()),
]
