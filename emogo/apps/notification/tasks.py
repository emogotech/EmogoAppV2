# from celery.decorators import task
# from celery.utils.log import get_task_logger

# from emogo.apps.users.models import UserOnlineStatus
# from django.contrib.auth.models import User
# from emogo.apps.stream.models import Stream, ContentComment, StreamContent
# from emogo.apps.collaborator.models import Collaborator
# from emogo.apps.notification.views import NotificationAPI
# from django.db.models import Prefetch

# logger = get_task_logger(__name__)

# @task(name="send_comment_notification")
# def send_comment_notification(stream_id, content_id, comment_id, from_user_id):
#         """
#         Check if stream creator and content creator are same then
#         We will send single notification.
#         If content and created by collaborator and that collaborator if
#         Removed from the emogo then wont send notification to that user
#         Otherwise we will notify both content creator and emogo creator.
#         """
#         stream = Stream.actives.select_related('created_by').prefetch_related(
#             Prefetch(
#                 'collaborator_list',
#                 queryset=Collaborator.actives.all().select_related('created_by'),
#                 to_attr='active_stream_collaborator'
#             )).get(id=stream_id)
#         content = StreamContent.objects.select_related(
#             "content").only("content").get(stream=stream,
#             content__id=content_id).content
#         comment = ContentComment.objects.get(id=comment_id)
#         from_user = User.objects.get(id=from_user_id)
#         if content.created_by != from_user and not UserOnlineStatus.objects.filter(
#             stream=stream, auth_token__user=content.created_by).exists():
#             if stream.type == "Public" or (stream.type == "Private" and any(
#                 True for collb in stream.active_stream_collaborator if \
#                 content.created_by.username.endswith(collb.phone_number[-10:]))):
#                 NotificationAPI().send_notification(from_user, content.created_by,
#                     'new_comment', stream, content, comment=comment)
#         if stream.created_by != content.created_by and \
#             stream.created_by != from_user and not UserOnlineStatus.objects.filter(
#             stream=stream, auth_token__user=stream.created_by).exists():
#             NotificationAPI().send_notification(from_user, stream.created_by,
#                     'new_comment', stream, content, comment=comment)
