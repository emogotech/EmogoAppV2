from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.notification.models import Notification
from emogo.apps.users.models import User
from faker import Faker
fake = Faker()


class BaseAPITests(APITestCase):
    fixtures = ('test_data',)

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.token = cls.test_user.auth_tokens.first()
        cls.header = {'HTTP_AUTHORIZATION': 'Token ' + str(cls.token)}
        cls.test_user_notification = cls.test_user.sender.last()


class NotificationTestCases(BaseAPITests):
    def setUp(self):
        super(NotificationTestCases, self).setUp()

    def test_for_get_activity_logs(self):
        self.url = f"{self.url}/activity_logs/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_badge_count(self):
        self.url = f"{self.url}/badge/count/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_decrease_badge_count(self):
        self.url = f"{self.url}/decrease/badge/count/"
        self.test_dict = {
            "notification_id": self.test_user_notification.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_decrease_badge_count_with_none(self):
        self.url = f"{self.url}/decrease/badge/count/"
        self.test_dict = {
            "notification_id": None
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_delete_notification_with_invalid_id(self):
        self.url = f"{self.url}/notification/delete/{fake.msisdn()}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_delete_notification_with_valid_id(self):
        self.url = f"{self.url}/notification/delete/{self.test_user_notification.id}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
