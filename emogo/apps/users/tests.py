from django.test import Client
from rest_framework.test import APITestCase
from rest_framework.views import status

from emogo.apps.users.models import User, UserProfile


class BaseAPITests(APITestCase):
    fixtures = ('test_data',)

    @classmethod
    def setUpTestData(cls):
        cls.url = '/api/v3'
        cls.test_user = User.objects.latest('id')
        cls.test_user_profile = UserProfile.objects.get(user_id=cls.test_user)


class UserSignupTestCase(BaseAPITests):
    def setUp(self):
        super(UserSignupTestCase, self).setUp()
        self.url = self.url + '/signup/'

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
        self.url = self.url + '/unique_user_name/'

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
        self.url = self.url + '/verify_otp/'

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
        self.url = self.url + '/login/'

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
        self.test_dict = {
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class SignOutTestCase(BaseAPITests):

    def setUp(self):
        super(SignOutTestCase, self).setUp()
        self.url = self.url + '/logout/'

    def test_user_for_signout(self):
        # User can signout
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_signout_all_devices(self):
        self.test_dict = {
            "logout_from_all_device": True
        }
        self.client.force_authenticate(self.test_user)
        response = self.client.post(self.url, data=self.test_dict)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_for_signout_without_token(self):
        # User can not signout without token
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class ResendOtpTestCase(BaseAPITests):
    def setUp(self):
        super(ResendOtpTestCase, self).setUp()
        self.url = self.url + '/resend_otp/'

    def test_resend_otp_with_invalid_phone_number(self):
        self.test_dict = {
            "phone_number": "+918103987"
        }
        response = self.client.post(self.url, data=self.test_dict, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_resend_otp_without_phone_number(self):
        self.test_dict = {
        }
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
        self.url = self.url + '/users'

    def test_filter_user_by_name(self):
        if self.test_user:
            self.url += '?people=' + str(self.test_user_profile.full_name)
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_filter_user_by_phone_number(self):
        if self.test_user:
            self.url += '?people=' + str(self.test_user.username)
        self.client.force_authenticate(self.test_user)
        response = self.client.get(self.url, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)