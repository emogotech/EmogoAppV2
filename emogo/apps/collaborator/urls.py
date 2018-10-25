from django.conf.urls import url
from emogo.apps.collaborator import views

urlpatterns = [
	url(r'^collaborator/(?P<invites>(accept|decline))/(?P<pk>[0-9]+)/$', views.CollaboratorInvitationAPI.as_view()),
]
