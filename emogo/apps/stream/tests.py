from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile, Token
from emogo.apps.stream.models import Stream, Folder


class BaseAPITests(APITestCase):

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.test_user_profile = UserProfile.objects.get(user_id=cls.test_user)
        cls.token = Token.objects.get_or_create(user=cls.test_user)
        cls.test_user_stream = Stream.objects.get(created_by_id=cls.test_user)
        cls.test_folder = Folder.objects.filter(owner_id=cls.test_user).values('id')


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


class StreamListingTestCase(BaseAPITests):
    def setUp(self):
        super(StreamListingTestCase, self).setUp()
        self.url = self.url + '/stream'

    def test_stream_list(self):
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_featured_true(self):
        self.url = self.url + '?featured=True'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_emogo_true(self):
        self.url = self.url + '?emogo=True'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_my_stream_true(self):
        self.url = self.url + '?my_stream=True'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_by_folder(self):
        folder = ''
        if self.test_folder:
            folder = '?folder=' + str(self.test_folder[0]['id'])
        self.url = self.url + folder
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_stream_list_with_filter_my_stream_and_stream_name(self):
        by_stream_name = ''
        if self.test_user_stream:
            by_stream_name += '&stream_name=' + str(self.test_user_stream.name)
        self.url = self.url + '?my_stream=True' + by_stream_name
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_by_folder_and_stream_name(self):
        folder, by_stream_name = '', ''
        if self.test_folder and self.test_user_stream:
            folder = '?folder=' + str(self.test_folder[0]['id'])
            by_stream_name += '&stream_name=' + str(self.test_user_stream.name)
        self.url = self.url + folder + by_stream_name
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_stream_with_pk(self):
        if self.test_user_stream:
            self.url += '/' + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.get(self.url, format='json', **header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_delete_stream_with_pk(self):
        if self.test_user_stream:
            self.url += '/' + str(self.test_user_stream.id) + '/'
        header = {'HTTP_AUTHORIZATION': 'Token ' + str(self.token[0])}
        response = self.client.delete(self.url, format='json', **header)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)
