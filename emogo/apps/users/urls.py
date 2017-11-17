from django.conf.urls import url
from emogo.apps.users import views

urlpatterns = [
    url(r'^signup/$', views.Signup.as_view()),
    url(r'^verify_otp/$', views.VerifyRegistration.as_view()),
    url(r'^login/$', views.Login.as_view()),
    url(r'^unique_user_name/$', views.UniqueUserName.as_view()),
    url(r'^resend_otp/$', views.ResendOTP.as_view()),
]