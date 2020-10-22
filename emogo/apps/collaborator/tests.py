from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.collaborator.models import Collaborator
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
        cls.test_user_stream = cls.test_user.stream_set.latest('id')
        cls.test_user_collaborator = cls.test_user_stream.collaborator_list.latest('id')
        cls.test_user_notification = cls.test_user.sender.last()


class CollaboratorTestCases(BaseAPITests):
    def setUp(self):
        super(CollaboratorTestCases, self).setUp()

    def test_for_update_invitation_accept(self):
        self.url = f"{self.url}/collaborator/accept/"
        self.test_dict={
            "stream": self.test_user_stream.id,
            "notification_id": self.test_user_notification.id
        }
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_update_invitation_decline(self):
        self.url = f"{self.url}/collaborator/decline/"
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "notification_id": self.test_user_notification.id
        }
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_404_NOT_FOUND)

    def test_for_destroy_invitation_decline(self):
        self.url = f"{self.url}/collaborator/decline/"
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "notification_id": self.test_user_notification.id
        }
        response = self.client.delete(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_collaborators_stream_with_true(self):
        self.url = f"{self.url}/collaborators_stream/{self.test_user_stream.id}/True/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_collaborators_stream_with_false(self):
        self.url = f"{self.url}/collaborators_stream/{self.test_user_stream.id}/False/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_delete_collaborator_with_invalid_id(self):
        self.url = f"{self.url}/collaborator/delete/{fake.msisdn()}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_delete_collaborator(self):
        self.url = f"{self.url}/collaborator/delete/{self.test_user_collaborator.id}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
