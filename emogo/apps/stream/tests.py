from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile, Token
from emogo.apps.stream.models import Stream, Folder, Content, StreamContent


class BaseAPITests(APITestCase):

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.test_user_profile = UserProfile.objects.get(user_id=cls.test_user)
        cls.token = Token.objects.get_or_create(user=cls.test_user)
        cls.test_user_stream = Stream.objects.filter(created_by_id=cls.test_user).order_by('-id')[0]
        cls.test_folder = Folder.objects.filter(owner_id=cls.test_user).values('id')
        cls.test_user_content = Content.objects.filter(created_by_id=cls.test_user).order_by('-id')[0]
        cls.test_user_stream_content = StreamContent.objects.filter(user_id=cls.test_user).order_by('-id')[0]


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

    def test_filter_stream_with_global_search(self):
        self.url += '?global_search=JULIE & SEAN/'
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class ContentTestCase(BaseAPITests):
    def setUp(self):
        super(ContentTestCase, self).setUp()
        self.url = self.url + '/content/'

    def test_for_create_content(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "zip",
                "name": "component-testing",
                "description": "This is first description.",
                "html_text": "this is html file text",
                "file": "test.html"
            }
        ]
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_create_content_without_type(self):
        # default type is video
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "name": "component-testing",
                "description": "This is first description.",
                "html_text": "this is html file text",
                "file": "test.html"
            }
        ]
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'][0]['type'], 'Video')

    def test_for_create_content_with_invalid_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "qqqqq",
                "name": "component-testing",
                "description": "This is first description.",
                "html_text": "this is html file text",
                "file": "test.html"
            }
        ]
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_content_with_blank_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "",
                "name": "component-testing",
                "description": "This is first description.",
                "html_text": "this is html file text",
                "file": "test.html"
            }
        ]
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_name_more_than_255_characters(self):
        self.test_dict = [
            {
                "name": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
                        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
                        " when an unknown printer took a galley of type and scrambled it to make a type "
                        "specimen book. It has survived not only five centuries, but also the leap into "
                        "electronic typesetting, remaining essentially unchanged."
            }
        ]
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update_with_blank_type(self):
        self.test_dict = {
                "type": "",
                "name": "component-testing",
                "file": "test.html"
            }
        self.url = self.url + str(self.test_user_content.id) + '/'
        self.client.force_authenticate(self.test_user)
        response = self.client.patch(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update_with_invalid_type(self):
        self.test_dict = {
            "type": "qqqqq",
            "name": "component-testing",
            "file": "test.html"
        }
        self.url = self.url + str(self.test_user_content.id) + '/'
        self.client.force_authenticate(self.test_user)
        response = self.client.patch(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update(self):
        self.test_dict = {
                "type": "zip",
                "name": "component-testing",
                "file": "test.html"
            }
        self.url = self.url + str(self.test_user_content.id) + '/'
        self.client.force_authenticate(self.test_user)
        response = self.client.patch(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing(self):
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_stream(self):
        if self.test_user_stream:
            self.url += '?stream=' + str(self.test_user_stream.id)
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_stream_and_content(self):
        if self.test_user_stream_content:
            self.url += '?stream=' + str(self.test_user_stream_content.stream_id) + '&content=' + \
                        str(self.test_user_stream_content.content_id)
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_invalid_stream(self):
        if self.test_user_stream:
            self.url += '?stream=' + str(self.test_user_stream.id) + '111'
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_content_listing_with_filter_by_invalid_stream_and_content(self):
        if self.test_user_stream_content:
            self.url += '?stream=' + str(self.test_user_stream_content.stream_id) + '111&content=' + \
                        str(self.test_user_stream_content.content_id) + '111'
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


class MoveContentToStreamTestCase(BaseAPITests):
    def setUp(self):
        super(MoveContentToStreamTestCase, self).setUp()
        self.url = self.url + '/move_content_to_stream/'

    def test_move_content_to_stream_with_content_blank(self):
        self.test_dict = {
            "contents": [],
            "streams": [self.test_user_stream.id]
        }
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream_with_stream_blank(self):
        self.test_dict = {
            "contents": [self.test_user_content.id],
            "streams": []
        }
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream_without_stream(self):
        self.test_dict = {
            "contents": [],
        }
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream(self):
        self.test_dict = {
            "contents": [self.test_user_content.id],
            "streams": [self.test_user_stream.id]
        }
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
