from django.conf.urls import url
from emogo.apps.stream import views

urlpatterns = [
    # url(r'^/stream/collaborators/(?P<pk>[0-9]+)/', views.StreamAPI.as_view(fields=), name='user-list')
    url(r'^stream/collaborator/(?P<pk>[0-9]+)/$', views.StreamAPI.as_view(), name='stream_collaborator'),
    url(r'^stream/(?P<pk>[0-9]+)/$', views.StreamAPI.as_view(), name='view_stream'),
    url(r'^stream/$', views.StreamAPI.as_view()),
    url('^stream', views.StreamAPI.as_view()),
    url('^like_dislike_stream', views.StreamLikeDislikeAPI.as_view()),
    url(r'^like_stream/(?P<stream_id>[0-9]+)/$', views.StreamLikeAPI.as_view()),
    url('^like_dislike_content', views.ContentLikeDislikeAPI.as_view()),
    url('^increase_view_count', views.IncreaseStreamViewCount.as_view()),
    # The API is created because developer unable to get link type content
    url(r'^delete_content/$', views.DeleteContentInBulk.as_view()),
    url(r'^content/link_type/$', views.LinkTypeContentAPI.as_view()),
    url(r'^content/(?P<pk>[0-9]+)/$', views.ContentAPI.as_view()),
    url(r'^content/$', views.ContentAPI.as_view()),
    url(r'^copy_content/$', views.CopyContentAPI.as_view()),
    url(r'^get_top_content/$', views.GetTopContentAPI.as_view()),
    url(r'^get_top_twenty_content/$', views.GetTopTwentyContentAPI.as_view()),
    url(r'^move_content_to_stream/$', views.MoveContentToStream.as_view()),
    url(r'^reorder_stream_content/$', views.ReorderStreamContent.as_view()),
    url(r'^reorder_content/$', views.ReorderContent.as_view()),
    url(r'^extremist_report/$', views.ExtremistReportAPI.as_view()),
    url(r'^delete_stream_content/(?P<pk>[0-9]+)/$', views.DeleteStreamContentAPI.as_view()),
    url(r'^bulk_delete_stream_content/(?P<pk>[0-9]+)/$', views.DeleteStreamContentInBulkAPI.as_view()),
    url(r'^bulk_contents', views.ContentInBulkAPI.as_view()),
    url(r'^content/share_extension', views.ContentShareExtensionAPI.as_view()),
    url(r'^recent_updates/$', views.RecentUpdatesAPI.as_view()),
    url(r'^recent_updates_detail/$', views.RecentUpdatesDetailListAPI.as_view()),
    url(r'^seen_index/$', views.SeenIndexAPI.as_view()),
    url(r'^starred_streams', views.StarredAPI.as_view()),
    url(r'^bookmarks/$', views.StarredStreamAPI.as_view()),# don't make a name starts with stream
    url(r'^bookmarks_and_new_emogos/$', views.BookmarkNewEmogosAPI.as_view()),
    url(r'^new_emogos_list', views.NewEmogosAPI.as_view()),

]
