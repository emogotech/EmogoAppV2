from django.test import Client
from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User
from emogo.apps.users.serializers import UserDetailSerializer
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
        cls.verify_otp_phone = User.objects.all().order_by('-id')


class UserSignupTestCase(BaseAPITests):
    def setUp(self):
        super(UserSignupTestCase, self).setUp()
        self.url = f"{self.url}/signup/"

    def test_for_create_user(self):
        self.test_dict = {
            "phone_number": "+911234567899",
            "user_name": "anonymous12"
        }
        # User create
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_create_user_with_no_username(self):
        self.test_dict = {
            "phone_number": "+911234567899"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_no_phone_number(self):
        self.test_dict = {
            "username": "anonymous12"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_preexisting_username(self):
        self.test_dict = {
            "phone_number": self.test_user.username,
            "user_name": self.test_user_profile.full_name
        }
        response = self.client.post(self.url, self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class UniqueUserTestCase(BaseAPITests):
    def setUp(self):
        super(UniqueUserTestCase, self).setUp()
        self.url = f"{self.url}/unique_user_name/"

    def test_unique_username_with_already_exist_username(self):
        self.test_dict = {
            "phone_number": self.test_user.username,
            "user_name": self.test_user_profile.full_name
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_username_availability(self):
        self.test_dict = {
            "phone_number": "+911234567899",
            "user_name": "anonymous"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class VerifyOtpTestCase(BaseAPITests):
    def setUp(self):
        super(VerifyOtpTestCase, self).setUp()
        self.url = f"{self.url}/verify_otp/"

    def test_verify_otp_without_phone_number(self):
        self.test_dict = {
            "phone_number": "",
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_without_otp(self):
        self.test_dict = {
            "phone_number": "+911234567899",
            "otp": "",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_otp_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+9112345678",
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_otp_with_invalid_otp(self):
        self.test_dict = {
            "phone_number": self.test_user.username,
            "otp": "1111111",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_otp(self):
        self.test_dict = {
            "phone_number": self.verify_otp_phone[1].username,
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserLoginTestCase(BaseAPITests):
    def setUp(self):
        super(UserLoginTestCase, self).setUp()
        self.url = f"{self.url}/login/"

    def test_user_login(self):
        self.test_dict = {
            "phone_number": self.test_user.username
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_login_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+9112345678"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_user_login_without_phone_number(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class SignOutTestCase(BaseAPITests):

    def setUp(self):
        super(SignOutTestCase, self).setUp()
        self.url = f"{self.url}/logout/"

    def test_user_for_signout(self):
        # User can signout
        response = self.client.post(self.url, **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_signout_all_devices(self):
        self.test_dict = {
            "logout_from_all_device": True
        }
        response = self.client.post(self.url, data=self.test_dict, **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_for_signout_without_token(self):
        # User can not signout without token
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class ResendOtpTestCase(BaseAPITests):
    def setUp(self):
        super(ResendOtpTestCase, self).setUp()
        self.url = f"{self.url}/resend_otp/"

    def test_resend_otp_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+91123456"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_resend_otp_without_phone_number(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_resend_otp(self):
        self.test_dict = {
            "phone_number": self.test_user.username
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserTestCase(BaseAPITests):
    def setUp(self):
        super(UserTestCase, self).setUp()
        self.test_user_stream = self.test_user.stream_set.latest('id')
        self.url = f"{self.url}/users"

    def test_filter_user_by_name(self):
        self.url = f"{self.url}?people={self.test_user_profile.full_name}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_filter_user_by_phone_number(self):
        self.url = f"{self.url}?people={self.test_user.username}"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_userprofile_by_id(self):
        self.url = f"{self.url}/{self.test_user.id}/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_userprofile_by_invalid_id(self):
        self.url = f"{self.url}/{fake.msisdn()}/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_update_userprofile(self):
        self.url = f"{self.url}/{self.test_user.id}/"
        self.test_dict = {
            "display_name": fake.name()
        }
        response = self.client.put(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_assign_stream_to_userprofile(self):
        self.url = f"{self.url}/{self.test_user.id}/"
        self.test_dict = {
            "location": fake.city_suffix(),
            "full_name": fake.name(),
            "website": fake.safe_domain_name(),
            "biography": fake.sentence(),
            "user_image": "https://s3.amazonaws.com/emogo-v2/stream-media/A39DBB27-F327-4F6B-BCAB-6CEBB70A58B2.png",
            "birthday": fake.date(),
            "profile_stream": self.test_user_stream.id
        }
        response = self.client.put(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_following_list(self):
        self.url = '/api/v3/get_user_following/'
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_search_user_by_name(self):
        self.url = f"{self.url}/?name=abc"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_user_following_list_filter_by_following_name(self):
        self.url = '/api/v3/get_user_following/?following_name=jon'
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_user_follower_list_filter_by_follower_name(self):
        self.url = '/api/v3/get_user_followers/?follower_name=clay'
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_user_delete_api(self):
        self.url = f"{self.url}/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserCollaboratorTestCase(BaseAPITests):
    def setUp(self):
        super(UserCollaboratorTestCase, self).setUp()
        self.url = f"{self.url}/user_collaborators/"

    def test_get_user_collaborators(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_user_collaborators_filter_by_stream_name(self):
        self.url = f"{self.url}?stream_name=my_stream"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserLikedStreamsListTestCase(BaseAPITests):
    def setUp(self):
        super(UserLikedStreamsListTestCase, self).setUp()
        self.url = f"{self.url}/user_liked_streams/"

    def test_get_user_liked_stream(self):
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_user_liked_stream_filter_by_stream_name(self):
        self.url = f"{self.url}?stream_name=my_stream"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class UserFollowTestCase(BaseAPITests):
    def setUp(self):
        super(UserFollowTestCase, self).setUp()
        self.url = f"{self.url}/follow_user/"

    def test_for_user_follow_without_request_param(self):
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_user_follow_with_following_blank(self):
        self.test_dict = {
            "following": ""
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_user_follow_with_valid_request_param(self):
        self.test_dict = {
            "following": self.test_user.who_is_followed.first().following_id
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)


class UserUnfollowTestCase(BaseAPITests):
    def setUp(self):
        super(UserUnfollowTestCase, self).setUp()
        self.url = f"{self.url}/unfollow_user/"

    def test_for_unfollow_user_with_invalid_kwargs(self):
        self.url = f"{self.url}{fake.msisdn()}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_for_unfollow_user(self):
        self.url = f"{self.url}{self.test_user.who_is_followed.first().following_id}/"
        response = self.client.delete(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_204_NO_CONTENT)


class UserStreamsTestCase(BaseAPITests):
    def setUp(self):
        super(UserStreamsTestCase, self).setUp()
        self.url = f"{self.url}/user_streams"

    def test_get_user_streams_filter_by_following_stream_true(self):
        self.url = f"{self.url}?following_stream=True"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_user_streams_filter_by_emogo_stream(self):
        self.url = f"{self.url}?emogo_stream=5"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_user_streams_filter_by_collab_stream(self):
        self.url = f"{self.url}?collab_stream=5"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_get_user_streams_filter_by_following_stream_and_stream_name(self):
        self.url = f"{self.url}?following_stream=True&stream_name=my_stream"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class OtherApiTestCase(BaseAPITests):
    def setUp(self):
        super(OtherApiTestCase, self).setUp()

    def test_for_check_contact_in_emogo_user_without_request_param(self):
        self.url = f"{self.url}/check_contact_in_emogo_user/"
        self.test_dict = {}
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_check_contact_in_emogo_user_with_blank_contact_list(self):
        self.url = f"{self.url}/check_contact_in_emogo_user/"
        self.test_dict = {
            "contact_list": []
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_for_check_contact_in_emogo_user(self):
        self.url = f"{self.url}/check_contact_in_emogo_user/"
        self.test_dict = {
            "contact_list": ["+911234567899"]
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']["+911234567899"], False)

    def test_for_check_is_business_account(self):
        self.url = f"{self.url}/is_buisness/"
        self.test_dict = {
            "is_buisness_account": "True"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_suggested_follow(self):
        self.url = f"{self.url}/suggested_follow/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_user_left_menu_data(self):
        self.url = f"{self.url}/user-left-menu-data/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_the_device_list_of_logged_in_user(self):
        self.url = f"{self.url}/user-loggedin-devices/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_top_stream_v3(self):
        self.url = f"{self.url}/get_top_stream_v3/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_notification_test(self):
        self.url = f"{self.url}/test-notify/"
        self.test_dict = {
            "device_token": str(self.token)
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_upload_media_on_s3(self):
        self.url = f"{self.url}/upload-media-on-s3/"
        response = self.client.post(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_for_get_top_stream_v2(self):
        self.url = f"{self.url}/get_top_stream_v2/"
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class VerifyLoginOtpTestCase(BaseAPITests):
    def setUp(self):
        super(VerifyLoginOtpTestCase, self).setUp()
        self.url = f"{self.url}/verify_login_otp/"

    def test_verify_login_otp_without_phone_number(self):
        self.test_dict = {
            "phone_number": "",
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_login_otp_without_otp(self):
        self.test_dict = {
            "phone_number": "+911234567899",
            "otp": "",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_login_otp_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+9112345678",
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_login_otp_with_invalid_otp(self):
        self.test_dict = {
            "phone_number": self.test_user.username,
            "otp": "1111111",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_login_otp(self):
        self.test_dict = {
            "phone_number": self.verify_otp_phone[1].username,
            "otp": "12345",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
