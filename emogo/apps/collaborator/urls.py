from django.conf.urls import url
from emogo.apps.collaborator import views

urlpatterns = [
	url(r'^collaborator/(?P<invites>(accept|decline))/$', views.CollaboratorInvitationAPI.as_view()),
	url(r'^collaborators_stream/(?P<stream>[0-9]+)/$', views.StreamCollaboratorsAPI.as_view()),
]
