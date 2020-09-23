from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile, Token
from emogo.apps.stream.models import Stream, Folder, Content, StreamContent
from faker import Faker
fake = Faker()


class BaseAPITests(APITestCase):
    fixtures = ('test_data',)

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.prefetch_related('user_data').latest('id')
        cls.test_user_profile = cls.test_user.user_data
        cls.token = Token.objects.get(user=cls.test_user)
        cls.header = {'HTTP_AUTHORIZATION': 'Token ' + str(cls.token)}
        cls.test_user_stream = Stream.objects.filter(created_by_id=cls.test_user).order_by('-id').first()
        cls.test_user_content = Content.objects.filter(created_by_id=cls.test_user).order_by('-id').first()


class StreamTestCase(BaseAPITests):
    def setUp(self):
        super(StreamTestCase, self).setUp()
        self.url = f"{self.url}/stream/"

    def test_create_stream_without_name(self):
        self.test_dict = {
            "type": "Public"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_without_type(self):
        self.test_dict = {
            "name": fake.name()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_with_invalid_type(self):
        self.test_dict = {
            "name": fake.name(),
            "type": "Publi"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_stream_with_already_exist_name(self):
        self.test_dict = {
            "name": self.test_user_stream.name,
            "type": "Public"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    # stream update testcases
    def test_update_stream_with_blank_name(self):
        self.test_dict = {
            "name": "",
            "type": "Public"
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_invalid_type(self):
        self.test_dict = {
            "name": fake.name(),
            "type": "p"
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_blank_type(self):
        self.test_dict = {
            "name": fake.name(),
            "type": ""
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_any_one_can_edit_blank(self):
        self.test_dict = {
            "name": fake.name(),
            "type": "Public",
            "any_one_can_edit": ""
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_update_stream_with_blank_emogo(self):
        self.test_dict = {
            "name": fake.name(),
            "type": "Public",
            "emogo": ""
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_view_stream_all_collaborator(self):
        self.url = f"{self.url}collaborator/977/"
        response = self.client.get(self.url, **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class StreamListingTestCase(BaseAPITests):
    def setUp(self):
        super(StreamListingTestCase, self).setUp()
        self.test_folder = Folder.objects.filter(owner_id=self.test_user).values('id')
        self.url = f"{self.url}/stream"

    def test_stream_list(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_featured_true(self):
        self.url = f"{self.url}?featured=True"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_emogo_true(self):
        self.url = f"{self.url}?emogo=True"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_my_stream_true(self):
        self.url = f"{self.url}?my_stream=True"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_by_folder(self):
        folder = ''
        if self.test_folder:
            folder = f"?folder={self.test_folder[0]['id']}"
        self.url = f"{self.url}{folder}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_my_stream_and_stream_name(self):
        by_stream_name = f"&stream_name={self.test_user_stream.name}"
        self.url = f"{self.url}?my_stream=True{by_stream_name}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_by_folder_and_stream_name(self):
        folder, by_stream_name = '', ''
        if self.test_folder and self.test_user_stream:
            folder = f"?folder={self.test_folder[0]['id']}"
            by_stream_name = f"&stream_name={self.test_user_stream.name}"
        self.url = f"{self.url}{folder}{by_stream_name}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_stream_with_pk(self):
        self.url = f"{self.url}/{self.test_user_stream.id}/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_delete_stream_with_pk(self):
        self.url = f"{self.url}/{self.test_user_stream.id}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)

    def test_filter_stream_with_global_search(self):
        self.url = f"{self.url}?global_search=JULIE&SEAN/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class ContentTestCase(BaseAPITests):
    def setUp(self):
        super(ContentTestCase, self).setUp()
        self.test_user_stream_content = StreamContent.objects.filter(user_id=self.test_user).order_by('-id')[0]
        self.url = f"{self.url}/content/"

    def test_for_create_content(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "zip",
                "name": fake.name(),
                "description": fake.sentence(),
                "html_text": fake.sentence(),
                "file": "test.html"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_create_content_without_type(self):
        # default type is video
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "name": fake.name(),
                "description": fake.sentence(),
                "html_text": fake.sentence(),
                "file": "test.html"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data'][0]['type'], 'Video')

    def test_for_create_content_with_invalid_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": fake.words(),
                "name": fake.name(),
                "description": fake.sentence(),
                "html_text": fake.sentence(),
                "file": "test.html"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_content_with_blank_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "",
                "name": fake.name(),
                "description": fake.sentence(),
                "html_text": fake.sentence(),
                "file": "test.html"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
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
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update_with_blank_type(self):
        self.test_dict = {
                "type": "",
                "name": fake.name(),
                "file": "test.html"
            }
        self.url = f"{self.url}{self.test_user_content.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update_with_invalid_type(self):
        self.test_dict = {
            "type": fake.words(),
            "name": fake.name(),
            "file": "test.html"
        }
        self.url = f"{self.url}{self.test_user_content.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_content_update(self):
        self.test_dict = {
                "type": "zip",
                "name": fake.name(),
                "file": "test.html"
            }
        self.url = f"{self.url}{self.test_user_content.id}/"
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_stream(self):
        self.url = f"{self.url}?stream={self.test_user_stream.id}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_stream_and_content(self):
        self.url = f"{self.url}?stream= {self.test_user_stream_content.stream_id}&content=" \
                   f"{self.test_user_stream_content.content_id}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_content_listing_with_filter_by_invalid_stream(self):
        self.url = f"{self.url}?stream= {self.test_user_stream.id}111"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_content_listing_with_filter_by_invalid_stream_and_content(self):
        self.url = f"{self.url}?stream= {self.test_user_stream_content.stream_id}111&content=" \
                   f"{self.test_user_stream_content.content_id}111"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_content_listing_filter_by_type_link(self):
        self.url = f"{self.url}?type=link/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_content_link_type(self):
        self.url = f"{self.url}link_type/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class MoveContentToStreamTestCase(BaseAPITests):
    def setUp(self):
        super(MoveContentToStreamTestCase, self).setUp()
        self.url = f"{self.url}/move_content_to_stream/"

    def test_move_content_to_stream_with_content_blank(self):
        self.test_dict = {
            "contents": [],
            "streams": [self.test_user_stream.id]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream_with_stream_blank(self):
        self.test_dict = {
            "contents": [self.test_user_content.id],
            "streams": []
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream_without_stream(self):
        self.test_dict = {
            "contents": [],
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_move_content_to_stream(self):
        self.test_dict = {
            "contents": [self.test_user_content.id],
            "streams": [self.test_user_stream.id]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class DeleteContentTestCase(BaseAPITests):
    def setUp(self):
        super(DeleteContentTestCase, self).setUp()
        self.url = f"{self.url}/delete_content/"

    def test_for_delete_content_without_content_list(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_delete_content_with_empty_content_list(self):
        self.test_dict = {
            "content_list": []
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_delete_content_with_content_list(self):
        self.test_dict = {
            "content_list": [self.test_user_content.id]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)


class DeleteStreamContentTestCase(BaseAPITests):
    def setUp(self):
        super(DeleteStreamContentTestCase, self).setUp()
        self.url = f"{self.url}/delete_stream_content/"

    def test_for_delete_stream_content_without_content(self):
        self.test_dict = {}
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.delete(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_delete_stream_content_with_blank_content(self):
        self.test_dict = {
            "content": []
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.delete(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_delete_stream_content_with_content(self):
        self.test_dict = {
            "content": [self.test_user_content.id]
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.delete(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class DragAndDropStreamContentTestCase(BaseAPITests):
    def setUp(self):
        super(DragAndDropStreamContentTestCase, self).setUp()
        self.url = f"{self.url}/reorder_stream_content/"

    def test_drag_and_drop_stream_content_without_stream(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_stream_content_without_content(self):
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_stream_content_with_blank_content(self):
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "content": [{}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_stream_content_without_order(self):
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "content": [{"id": self.test_user_content.id}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_stream_content_without_id(self):
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "content": [{"order": 1}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_stream_content(self):
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "content": [{"id": self.test_user_content.id, "order": 1}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
