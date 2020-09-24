from django.test import Client
from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile, Token
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


class UserSignupTestCase(BaseAPITests):
    def setUp(self):
        super(UserSignupTestCase, self).setUp()
        self.url = f"{self.url}/signup/"

    def test_for_create_user(self):
        self.test_dict = {
            "phone_number": "+918103987731",
            "user_name": "akash968"
        }
        # User create
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['status_code'], status.HTTP_201_CREATED)

    def test_create_user_with_no_username(self):
        self.test_dict = {
            "phone_number": "+918103987732"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_create_user_with_no_phone_number(self):
        self.test_dict = {
            "username": "vivek968"
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
            "phone_number": "+918103987736",
            "user_name": "akash968"
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
            "phone_number": "+918103987732",
            "otp": "",
            "device_name": "mac"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_verify_otp_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+9181039877",
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
            "phone_number": "+919751562896",
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
            "phone_number": "+9181039877"
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
            "phone_number": "+918103987"
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
            "profile_stream": "2402"
        }
        response = self.client.put(self.url, data=self.test_dict, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_following_list(self):
        self.url = '/api/v3/get_user_following/'
        response = self.client.get(self.url, format='json', **self.header)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_search_user_by_name(self):
        self.url = f"{self.url}/?name=vivek"
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
        self.url = f"{self.url}?stream_name=my stream"
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
            "following": "2"
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
        self.url = f"{self.url}2/"
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
