from drf_yasg import openapi

signup_schema_doc = openapi.Schema(type=openapi.TYPE_OBJECT,
                                   required=['phone_number', 'user_name'],
    properties={
        'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Phone Number', maxLength=20, minLength=1),
        'user_name': openapi.Schema(type=openapi.TYPE_STRING, 
                title='UserName', maxLength=100, minLength=1)
    },
    example={
        'phone_number': "+919827121212",
        "user_name":"Rahul"
    }
)

verify_reg_schema_doc = openapi.Schema(type=openapi.TYPE_OBJECT,
                                   required=['phone_number', 'otp'],
    properties={
        'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Phone Number', maxLength=20, minLength=1),
        'otp': openapi.Schema(type=openapi.TYPE_STRING, 
                title='otp', maxLength=10, minLength=1),
        'device_name': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Device Name', maxLength=100, minLength=1)
    },
    example={
        'phone_number': "+919827121212",
        "otp": "12345",
        "device_name": "mac"
    }
)

user_profile_update_schema_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['phone_number', 'user_image'],
    properties={
        'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Phone Number', maxLength=60, minLength=1),
        'user_image': openapi.Schema(type=openapi.TYPE_STRING, 
                title='User Image', maxLength=60, minLength=1)
    },
    example={
	  "phone_number": "+918120256863",
	  "user_image": "https://www.google.co.in/search?"
    }
)

user_profile_update_response =  {
    '200': """{
        "status_code": 200,
        "data": {
            "phone_number": "+918120256863",
            "user_profile_id": 48,
            "user_id": "49",
            "user_image": "https://www.google.co.in/search?q=profile+image&tbm=isch&source=iu&ictx=1&fir=WzmuRrJbIKhmjM%253A%252CNxKkcMJiw9mT2M%252C_&usg=__VaNMTTjto-DvP2J0v9J7RYY28C4%3D&sa=X&ved=0ahUKEwjv_MXM2MrYAhVC7VMKHfRWBOgQ9QEILDAC#",
            "profile_stream": {},
            "followers": 0,
            "following": 0,
            "is_following": false,
            "is_follower": false,
            "full_name": "Newuser",
            "display_name": "Aarti",
            "location": "",
            "website": "",
            "biography": "",
            "birthday": "",
            "branchio_url": "https://ysfd.app.link/PUXAPqRtZM"
        }
    }""",
}

check_content_avail_schema = openapi.Schema(
    type=openapi.TYPE_OBJECT,
    required=['contact_list'],
    properties={
        "contact_list": openapi.Schema(
            type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_STRING)
        )
    },
    example={
        "contact_list":["+911472580369", "+17813677669", "+919669885398"]
        
    }
)

check_content_avail_responses =  {
    '200': """{
    "status_code": 200,
    "data": {
        "status_code": 200,
        "data": {
            "+17813677669": {
                "phone_number": "+17813677669",
                "user_profile_id": 12,
                "user_id": "12",
                "user_image": "https://s3.amazonaws.com/emogo-v2/testing/B6641A9A-F8FB-49FD-ABF5-41E9549D30DC.png",
                "full_name": "jon",
                "display_name": "Jonathan Woods"
            },
            "+911472580369": {
                "phone_number": "+911472580369",
                "user_profile_id": 26,
                "user_id": "26",
                "user_image": "",
                "full_name": "Zzz",
                "display_name": null
            }
        }
    }""",
}

check_is_business_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['is_buisness_account'],
    properties={
        'is_buisness_account': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Is Business Account', maxLength=60, minLength=1),
    },
    example= { "is_buisness_account":"True" }
)

verify_otp_fields = {
    'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
            title='Phone Number', maxLength=20, minLength=1),
    'otp': openapi.Schema(type=openapi.TYPE_STRING, 
            title='otp', maxLength=10, minLength=1),
    'device_name': openapi.Schema(type=openapi.TYPE_STRING, 
            title='Device Name', maxLength=100, minLength=1),
    "device_to_logout": openapi.Schema(
            type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER))
}

verify_login_otp_schema = openapi.Schema(type=openapi.TYPE_OBJECT,
                                   required=['phone_number', 'otp'],
    properties=verify_otp_fields,
    example={
        'phone_number': "+919827121212",
        "otp": "12345",
        "device_name": "mac",
        "device_to_logout": [53, 54]
    }
)

verify_login_otp_response = {
    '200': """{
        "status_code": 200,
        "data": {
            "token": "5deb1a301012af804b209e351aaba04170a92515",
            "phone_number": "+919165142005",
            "user_profile_id": 94,
            "user_id": "95",
            "user_image": null,
            "followers": 0,
            "following": 0,
            "full_name": "Rahul",
            "display_name": null,
            "location": null,
            "website": null,
            "biography": null,
            "birthday": null,
            "branchio_url": "https://ysfd.app.link/UpffsyHOk1"
        }
    }""",
}

login_schema_doc = openapi.Schema(type=openapi.TYPE_OBJECT, required=['phone_number'],
    properties={
        'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Phone Number', maxLength=20, minLength=1)
    },
    example={
        'phone_number': "+919827121212",
    }
)

login_api_response = {
    '200': """{
        "status_code": 200,
        "data": {
            "phone_number": "+917770888987",
            "user_profile_id": 717,
            "user_id": "719",
            "user_image": null,
            "followers": 0,
            "following": 0,
            "full_name": "prashants",
            "display_name": null,
            "exceed_login_limit": true,
            "logged_in_devices": {
                "131": {
                    "name": "mac",
                    "date": "04/05/2020 08:57"
                },
                "133": {
                    "name": "device-1",
                    "date": "04/05/2020 13:52"
                },
                "138": {
                    "name": "device-2",
                    "date": "05/05/2020 07:26"
                },
                "196": {
                    "name": "mac",
                    "date": "11/05/2020 13:47"
                },
                "197": {
                    "name": "mac",
                    "date": "11/05/2020 13:47"
                }
            }
        }
    }""",
}

logout_schema_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT,
    properties={
        'logout_from_all_device': openapi.Schema(type=openapi.TYPE_BOOLEAN, 
            title='You want to logout from all the devices?'),
    },
    example={
        "logout_from_all_device": True
    }
)

uniq_username_schema_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['user_name'],
    properties={
        'user_name': openapi.Schema(type=openapi.TYPE_STRING, 
                title='UserName', maxLength=60, minLength=1)
    },
    example={
        "user_name":"swarnim"
    }
)

uniq_username_schema_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['phone_number'],
    properties={
        'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Phone Number', maxLength=60, minLength=1)
    },
    example={
        "phone_number":"+919165142005"
    }
)