from django.conf.urls import url
from emogo.apps.users import views

urlpatterns = [
    url(r'^users/(?P<pk>[0-9]+)/$', views.Users.as_view()),
    url(r'^users/$', views.Users.as_view()),
    url('^users', views.Users.as_view()),
    url(r'^signup/$', views.Signup.as_view()),
    url(r'^verify_otp/$', views.VerifyRegistration.as_view()),
    url(r'^login/$', views.Login.as_view()),
    url(r'^unique_user_name/$', views.UniqueUserName.as_view()),
    url(r'^resend_otp/$', views.ResendOTP.as_view()),
    url(r'^logout/$', views.Logout.as_view()),
    url(r'^user_streams/$', views.UserSteams.as_view()),
    url(r'^user_collaborators/$', views.UserCollaborators.as_view()),
]