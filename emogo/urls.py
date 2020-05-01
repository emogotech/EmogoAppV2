"""emogo URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.11/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.conf.urls import url, include
    2. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.conf.urls import url, include
from django.conf import settings
from django.conf.urls.static import static
from emogo.apps.users import views
urlpatterns = [
    #url('', views.index),
    url(r'^admin/', admin.site.urls),
    # url(r'^health/', include('health_check.urls')),
    url(r'^api/((?P<version>(v3))/)?', include('emogo.apps.users.urls')),
    url(r'^api/((?P<version>(v3))/)?', include('emogo.apps.stream.urls')),
    url(r'^api/((?P<version>(v3))/)?', include('emogo.apps.collaborator.urls')),
    url(r'^api/((?P<version>(v3))/)?', include('emogo.apps.notification.urls')),
]
# urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
handler500 = 'emogo.apps.users.views.api_500'
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
