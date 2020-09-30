from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User
from faker import Faker
fake = Faker()


class BaseAPITests(APITestCase):
    fixtures = ('test_data',)

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.test_user_profile = cls.test_user.user_data
        cls.token = cls.test_user.auth_tokens.first()
        cls.header = {'HTTP_AUTHORIZATION': 'Token ' + str(cls.token)}
        cls.test_user_stream = cls.test_user.stream_set.latest('id')
        cls.test_user_content = cls.test_user.content_set.latest('id')
        cls.test_folder = cls.test_user.owner_folders.latest('id')
        cls.test_user_stream_content = cls.test_user.streamcontent_set.latest('id')


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
        self.url = f"{self.url}collaborator/{self.test_user_stream.id}/"
        response = self.client.get(self.url, **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class StreamListingTestCase(BaseAPITests):
    def setUp(self):
        super(StreamListingTestCase, self).setUp()
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
        folder = f"?folder={self.test_folder.id}"
        self.url = f"{self.url}{folder}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_my_stream_and_stream_name(self):
        by_stream_name = f"&stream_name={self.test_user_stream.name}"
        self.url = f"{self.url}?my_stream=True{by_stream_name}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_stream_list_with_filter_by_folder_and_stream_name(self):
        folder = f"?folder={self.test_folder.id}"
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
        """default type is video"""
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

    def test_for_get_content_notes_type(self):
        self.url = f"{self.url}?type=Note"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_create_note_type_content_with_invalid_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": fake.words(),
                "name": fake.name(),
                "description": fake.sentence(),
                "video_image": fake.sentence(),
                "height": 500,
                "width": 250,
                "color": "red"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_note_type_content_with_blank_type(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "",
                "name": fake.name(),
                "description": fake.sentence(),
                "video_image": fake.sentence(),
                "height": 500,
                "width": 250,
                "color": "red"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_note_type_content(self):
        self.test_dict = [
            {
                "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn"
                       ":ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
                "type": "Note",
                "name": fake.name(),
                "description": fake.sentence(),
                "video_image": fake.sentence(),
                "height": 500,
                "width": 250,
                "color": "red"
            }
        ]
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)
        
    def test_for_content_share_extension(self):
        self.url = f"{self.url}share_extension/"
        self.test_dict = {
            "contents": fake.name()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class MoveContentToStreamTestCase(BaseAPITests):
    """ request params: list of content_id and list of stream_id """
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
    """ Reorder stream content
        request params: stream_id and content:[{'id':xxx, 'order':1},{'id':yyy,'order':2 },...]
    """
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


class DragAndDropMyStuffTestCase(BaseAPITests):
    """
    reorder content
    request params: my_order : [{'id':xxx,'order':1}, {'id':yyy,'order':2},...]
    """
    def setUp(self):
        super(DragAndDropMyStuffTestCase, self).setUp()
        self.url = f"{self.url}/reorder_content/"

    def test_drag_and_drop_my_stuff_without_my_order(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_my_stuff_with_blank_my_order(self):
        self.test_dict = {
            "my_order": [{}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_my_stuff_without_order(self):
        self.test_dict = {
            "my_order": [{"id": self.test_user_content.id}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_my_stuff_without_content_id(self):
        self.test_dict = {
            "my_order": [{"order": 1}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_my_stuff_with_invalid_my_content_id(self):
        self.test_dict = {
            "my_order": [{"id": fake.msisdn(), "order": 1}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.data['status_code'], status.HTTP_400_BAD_REQUEST)

    def test_drag_and_drop_my_stuff_with_valid_request_param(self):
        self.test_dict = {
            "my_order": [{"id": self.test_user_content.id, "order": 1}]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class LikeDislikeStreamTestCase(BaseAPITests):
    def setUp(self):
        super(LikeDislikeStreamTestCase, self).setUp()
        self.url = f"{self.url}/like_dislike_stream/"

    def test_like_dislike_stream_without_stream(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_stream_with_blank_stream(self):
        self.test_dict = {
            "stream": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_stream_without_status(self):
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_stream_with_valid_request_param(self):
        self.test_dict = {
            "stream": self.test_user_stream.id,
            "status": 1
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)


class LikeDislikeContentTestCase(BaseAPITests):
    def setUp(self):
        super(LikeDislikeContentTestCase, self).setUp()
        self.url = f"{self.url}/like_dislike_content/"

    def test_like_dislike_content_without_request_param(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_content_with_blank_content(self):
        self.test_dict = {
            "content": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_content_without_status(self):
        self.test_dict = {
            "content": self.test_user_content.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_like_dislike_content_with_valid_request_param(self):
        self.test_dict = {
            "content": self.test_user_content.id,
            "status": 1
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)


class IncreaseStreamViewStatusTestCase(BaseAPITests):
    def setUp(self):
        super(IncreaseStreamViewStatusTestCase, self).setUp()
        self.url = f"{self.url}/increase_view_count/"

    def test_increase_view_count_without_request_param(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_increase_view_count_with_blank_stream(self):
        self.test_dict = {
            "stream": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_increase_view_count(self):
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)


class OtherStreamTestCase(BaseAPITests):
    def setUp(self):
        super(OtherStreamTestCase, self).setUp()

    def test_for_stream_search_for_add_content(self):
        self.url = f"{self.url}/stream-search-for-add-content?name=emo"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_top_content(self):
        self.url = f"{self.url}/get_top_content/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_extremist_report(self):
        self.url = f"{self.url}/extremist_report/"
        self.test_dict = {
            "user_comment": fake.sentence(),
            "type": "Inappropriate"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_bulk_contents(self):
        self.url = f"{self.url}/bulk_contents/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_recent_updates(self):
        self.url = f"{self.url}/recent_updates/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_seen_index_with_string_seen_index(self):
        self.url = f"{self.url}/seen_index/"
        self.test_dict = {
            "thread": fake.word(),
            "seen_index": "a"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_seen_index(self):
        self.url = f"{self.url}/seen_index/"
        self.test_dict = {
            "thread": fake.word(),
            "seen_index": 1
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_starred_streams_without_request_param(self):
        self.url = f"{self.url}/starred_streams/"
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_starred_streams_with_blank_stream(self):
        self.url = f"{self.url}/starred_streams/"
        self.test_dict = {
            "stream": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_starred_streams_with_invalid_stream(self):
        self.url = f"{self.url}/starred_streams/"
        self.test_dict = {
            "stream": fake.msisdn()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_starred_streams_with_valid_stream(self):
        self.url = f"{self.url}/starred_streams/"
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_bookmarks_api_without_request_param(self):
        self.url = f"{self.url}/bookmarks/"
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_bookmarks_api_with_blank_stream(self):
        self.url = f"{self.url}/bookmarks/"
        self.test_dict = {
            "stream": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_bookmarks_api_with_invalid_stream(self):
        self.url = f"{self.url}/bookmarks/"
        self.test_dict = {
            "stream": fake.msisdn()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_bookmarks_api_with_valid_stream(self):
        self.url = f"{self.url}/bookmarks/"
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_get_new_emogos_list(self):
        self.url = f"{self.url}/new_emogos_list/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_update_user_view_stream_status_without_request_param(self):
        self.url = f"{self.url}/update_user_view_stream_status/"
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_update_user_view_stream_status_with_blank_stream(self):
        self.url = f"{self.url}/update_user_view_stream_status/"
        self.test_dict = {
            "stream": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_update_user_view_stream_status_with_invalid_stream(self):
        self.url = f"{self.url}/update_user_view_stream_status/"
        self.test_dict = {
            "stream": fake.msisdn()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_update_user_view_stream_status_with_valid_stream(self):
        self.url = f"{self.url}/update_user_view_stream_status/"
        self.test_dict = {
            "stream": self.test_user_stream.id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_get_not_yet_added_content(self):
        self.url = f"{self.url}/content_not_yet_added/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_emogo_move_to_folder_with_invalid_stream(self):
        self.url = f"{self.url}/emogo-move-to-folder/{fake.msisdn()}/"
        response = self.client.patch(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_emogo_move_to_folder_without_request_param(self):
        self.url = f"{self.url}/emogo-move-to-folder/{self.test_user_stream.id}/"
        self.test_dict = {}
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_emogo_move_to_folder_with_empty_folder_id(self):
        self.url = f"{self.url}/emogo-move-to-folder/{self.test_user_stream.id}/"
        self.test_dict = {
            "folder": []
        }
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_emogo_move_to_folder_with_invalid_folder_id(self):
        self.url = f"{self.url}/emogo-move-to-folder/{self.test_user_stream.id}/"
        self.test_dict = {
            "folder": [fake.msisdn()]
        }
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_emogo_move_to_folder(self):
        self.url = f"{self.url}/emogo-move-to-folder/{self.test_user_stream.id}/"
        self.test_dict = {
            "folder": [self.test_folder.id]
        }
        response = self.client.patch(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_delete_all_comments_of_emogo_with_invalid_stream_id(self):
        self.url = f"{self.url}/streams/{fake.msisdn()}/delete_comments/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_delete_all_comments_of_emogo(self):
        self.url = f"{self.url}/streams/{self.test_user_stream.id}/delete_comments/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)


class BulkDeleteStreamContentTestCase(BaseAPITests):
    def setUp(self):
        super(BulkDeleteStreamContentTestCase, self).setUp()
        self.url = f"{self.url}/bulk_delete_stream_content/"

    def test_for_bulk_delete_stream_content_without_content(self):
        self.test_dict = {}
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_bulk_delete_stream_content_with_blank_content(self):
        self.test_dict = {
            "content": []
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_bulk_delete_stream_content_with_content(self):
        self.test_dict = {
            "content": [self.test_user_content.id]
        }
        self.url = f"{self.url}{self.test_user_stream.id}/"
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)


class FolderTestCase(BaseAPITests):
    def setUp(self):
        super(FolderTestCase, self).setUp()
        self.url = f"{self.url}/folder/"

    def test_for_create_new_folder_without_request_param(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_new_folder_with_blank_name(self):
        self.test_dict = {
            "name": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_create_new_folder(self):
        self.test_dict = {
            "name": fake.name()
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_for_get_list_of_folders_for_logged_in_user(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_delete_folder_with_invalid_folder_id(self):
        self.url = f"{self.url}{fake.msisdn()}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_delete_folder(self):
        self.url = f"{self.url}{self.test_folder.id}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_update_folder_with_invalid_folder_id(self):
        self.url = f"{self.url}{fake.msisdn()}/"
        response = self.client.put(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_update_folder_with_blank_name(self):
        self.url = f"{self.url}{fake.msisdn()}/"
        self.test_dict = {
            "name": ""
        }
        response = self.client.put(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_update_folder_with_blank_name(self):
        self.url = f"{self.url}{self.test_folder.id}/"
        self.test_dict = {
            "name": "folder_new_name"
        }
        response = self.client.put(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class ShareContentInImessageTestCase(BaseAPITests):
    def setUp(self):
        super(ShareContentInImessageTestCase, self).setUp()
        self.url = f"{self.url}/share-content-in-imessage/"

    def test_for_share_content_in_imessage_without_request_param(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_share_content_in_imessage_with_blank_content_id(self):
        self.test_dict = {
            "content": []
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_share_content_in_imessage_with_invalid_content_id(self):
        self.test_dict = {
            "content": [fake.msisdn()]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_share_content_in_imessage(self):
        self.test_dict = {
            "content": [self.test_user_content.id]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_list_of_share_content_in_imessage(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class GetStreamContentTestCase(BaseAPITests):
    def setUp(self):
        super(GetStreamContentTestCase, self).setUp()
        self.url = f"{self.url}/get_stream_content/"

    def test_for_get_stream_content_with_invalid_stream(self):
        self.url = f"{self.url}?stream={fake.msisdn()}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_get_stream_content_with_invalid_content(self):
        self.url = f"{self.url}?stream={self.test_user_stream_content.stream_id}&content={fake.msisdn()}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_get_stream_content(self):
        self.url = f"{self.url}?stream={self.test_user_stream_content.stream_id}&content=" \
                   f"{self.test_user_stream_content.content_id}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_stream_content_with_valid_stream(self):
        self.url = f"{self.url}?stream={self.test_user_stream_content.stream_id}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
