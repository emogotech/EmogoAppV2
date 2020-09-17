from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile, Token
from emogo.apps.stream.models import Stream


class BaseAPITests(APITestCase):

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.test_user_profile = UserProfile.objects.get(user_id=cls.test_user)
        cls.token = Token.objects.get_or_create(user=cls.test_user)
        cls.test_user_stream = Stream.objects.get(created_by_id=cls.test_user)
        Stream.objects.create()


class StreamTestCase(BaseAPITests):
    def setUp(self):
        super(StreamTestCase, self).setUp()
        self.url = self.url + '/stream/'

    def test_create_stream_without_name(self):
        self.test_dict = {
            "type": "Public"
        }
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.post(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_without_type(self):
        self.test_dict = {
            "name": "Stream Name"
        }
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.post(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_with_invalid_type(self):
        self.test_dict = {
            "name": "stream name",
            "type": "Publi"
        }
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.post(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_with_already_exist_name(self):
        self.test_dict = {
            "name": self.test_user_stream.name,
            "type": "Public"
        }
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.post(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    # stream update testcases
    def test_update_stream_with_blank_name(self):
        self.test_dict = {
            "name": "",
            "type": "Public"
        }
        self.url = self.url + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_invalid_type(self):
        self.test_dict = {
            "name": "abc",
            "type": "p"
        }
        self.url = self.url + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_blank_type(self):
        self.test_dict = {
            "name": "abc",
            "type": ""
        }
        self.url = self.url + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_any_one_can_edit_blank(self):
        self.test_dict = {
            "name": "abc",
            "type": "Public",
            "any_one_can_edit": ""
        }
        self.url = self.url + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_blank_emogo(self):
        self.test_dict = {
            "name": "abc",
            "type": "Public",
            "emogo": ""
        }
        self.url = self.url + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
