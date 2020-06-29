from drf_yasg import openapi

stream_schema_doc = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['name'],
	properties={
	    'name': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='name', maxLength=100, minLength=1),
	    'description': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='Description', maxLength=100, minLength=1),
	    'color': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='Color', maxLength=100, minLength=1),
	    'image': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='Image', maxLength=100, minLength=1),
	    'type': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='Type', maxLength=100, minLength=1),
	    'featured': openapi.Schema(type=openapi.TYPE_STRING, 
	            title='Featured', maxLength=100, minLength=1),
	    'height': openapi.Schema(type=openapi.TYPE_INTEGER, title='name'),
	    'width': openapi.Schema(type=openapi.TYPE_INTEGER, title='Width'),
	    'any_one_can_edit': openapi.Schema(type=openapi.TYPE_BOOLEAN, 
	            title='Anyone Can Edit'),
	    "collaborator": openapi.Schema(
    		type=openapi.TYPE_ARRAY,
            items=openapi.Items(type=openapi.TYPE_OBJECT,
            	required=['phone_number', 'name', 'status', 'new_add'],
				properties={
				    'name': openapi.Schema(type=openapi.TYPE_STRING, 
				            title='name', maxLength=100, minLength=1),
				    'phone_number': openapi.Schema(type=openapi.TYPE_STRING, 
				            title='Phone Number', maxLength=100, minLength=1),
				    'status': openapi.Schema(type=openapi.TYPE_STRING, 
				            title='Status', maxLength=100, minLength=1),
				    'new_add': openapi.Schema(type=openapi.TYPE_BOOLEAN, title='New Add'),
				},
			)
        ),
        "collaborator_permission": openapi.Schema(
    		type=openapi.TYPE_OBJECT,
        	required=['can_add_content', 'can_add_people'],
			properties={
			    'can_add_content': openapi.Schema(type=openapi.TYPE_BOOLEAN, 
            		title='Can Add Content'),
			    'can_add_people': openapi.Schema(type=openapi.TYPE_BOOLEAN, 
            		title='Can Add People'),
			}
        ),
	},
	example={
	    "name": "Stream with V3",
	    "description": "creqate d stream a from v3 url",
	    "color": "red",
	    "category": None,
	    "image": "https://trello.com/image.png",
	    "type": "Public",
	    "featured": True,
	    "height": 400,
	    "width": 400,
	    "any_one_can_edit": False,
	    "content": [ ],
	    "collaborator": [
	        {
	            "name": "update v3 collab 7",
	            "phone_number": "+17815046306",
	            "status": "Unverified",
	            "new_add": False
	        }
	    ],
	    "collaborator_permission": {
	        "can_add_content": True,
	        "can_add_people": False
	    }
	}
)


stream_api_responses = {
    '200': """{
	    "status_code": 201,
	    "data": {
	        "id": 1972,
	        "collaborator_permission": {
	            "can_add_content": true,
	            "can_add_people": false
	        },
	        "folder": null,
	        "author": "pc",
	        "contents": [ ],
	        "stream_permission": {
	            "can_add_content": true,
	            "can_add_people": true
	        },
	        "total_collaborator": 0,
	        "view_count": 0,
	        "total_likes": 0,
	        "user_liked": [],
	        "liked": false,
	        "user_image": null,
	        "is_collaborator": "0",
	        "collab_images": [],
	        "total_stream_collaborators": 5,
	        "have_some_update": false,
	        "crd": "2020-04-15T10:46:14.265157Z",
	        "upd": "2020-04-15T10:46:14.272541Z",
	        "status": "Active",
	        "name": "Stream with V3",
	        "description": "creqate d stream a from v3 url",
	        "image": "https://trello.com/image.png",
	        "type": "Public",
	        "any_one_can_edit": false,
	        "featured": true,
	        "emogo": false,
	        "height": "400",
	        "width": "400",
	        "color": "red",
	        "category": null,
	        "created_by": 604
	    }
	}""",
}

content_fields = {
    'url': openapi.Schema(type=openapi.TYPE_STRING, 
            title='url', maxLength=200, minLength=1),
    'type': openapi.Schema(type=openapi.TYPE_STRING, 
            title='Type', maxLength=100, minLength=1),
    'name': openapi.Schema(type=openapi.TYPE_STRING, 
            title='Name', maxLength=100, minLength=1),
    'description': openapi.Schema(type=openapi.TYPE_STRING, 
            title='Description', maxLength=100, minLength=1),
    'html_text': openapi.Schema(type=openapi.TYPE_STRING, 
            title='HTML Text', maxLength=100, minLength=1),
    'file': openapi.Schema(type=openapi.TYPE_STRING, 
            title='File', maxLength=100, minLength=1),
}

content_fields_example = {
    "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
    "type": "excel",
    "name": "component-1",
    "description": "This is first description.",
    "html_text": "this is html2",
    "file": "test.html"
}

content_schema_doc = openapi.Schema(
	type=openapi.TYPE_ARRAY,
    items=openapi.Items(type=openapi.TYPE_OBJECT,
    	required=['name', 'type'],
		properties=content_fields,
	),
	example=[content_fields_example]
)

content_api_responses = {
    '200': """{
	    "status_code": 201,
	    "data": [
	        {
	            "id": 21779,
	            "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
	            "user_image": null,
	            "full_name": "pc",
	            "created_by": 604,
	            "name": "component-1",
	            "description": "This is first description.",
	            "type": "excel",
	            "video_image": null,
	            "height": "300",
	            "width": "300",
	            "color": null,
	            "order": 0,
	            "html_text": "this is html2",
	            "file": "test.html"
	        }
	    ]
	}""",
}

content_update_api_response = {
    '200': """{
	    "status_code": 200,
	    "data": {
	        "id": 21825,
	        "url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRnkUxsZ0kpbI8nqOhCouv5YoTGCZFpbu3L3A__dggghttRsbWWZA",
	        "user_image": null,
	        "full_name": "Reena P",
	        "created_by": 10,
	        "liked": false,
	        "name": "component-1",
	        "description": "This is first description.",
	        "type": "excel",
	        "video_image": null,
	        "height": "300",
	        "width": "300",
	        "color": null,
	        "order": 0,
	        "html_text": "this is html2 new",
	        "file": "text2.txt"
	    }
	}""",
}

content_update_schema_doc = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['name', 'type'],
	properties=content_fields,
	example=content_fields_example
)

move_content_to_stream_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['contents', 'streams'],
    properties={
		"contents": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    ),
	    "streams": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    )
	},
	example={
		"contents":[87,88,89, 8616],
 	   	"streams" : [1321]
	}
)

delete_content_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['content_list'],
    properties={
		"content_list": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    )
	},
	example={
	    "content_list":[10,11]
	}
)

delete_stream_content_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['content'],
    properties={
		"content": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    )
	},
	example={
	    "content":[10,11]
	}
)

reorder_stream_content_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['stream', 'content'],
	properties={
	    'stream': openapi.Schema(type=openapi.TYPE_INTEGER, title='Stream'),
	    "content": openapi.Schema(
    		type=openapi.TYPE_ARRAY,
            items=openapi.Items(type=openapi.TYPE_OBJECT,
            	required=['id', 'order'],
				properties={
				    'id': openapi.Schema(type=openapi.TYPE_INTEGER, title='ID'),
				    'order': openapi.Schema(type=openapi.TYPE_INTEGER, title='Order'),
				},
			)
        ),
	},
	example={
	    "stream":363,
	    "content":[{"id":3574,"order":1}, {"id":3573,"order":2}]
	}
)

reorder_content_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['my_order'],
	properties={
	    "my_order": openapi.Schema(
    		type=openapi.TYPE_ARRAY,
            items=openapi.Items(type=openapi.TYPE_OBJECT,
            	required=['id', 'order'],
				properties={
				    'id': openapi.Schema(type=openapi.TYPE_INTEGER, 
	            		title='ID', description='ID'),
				    'order': openapi.Schema(type=openapi.TYPE_INTEGER, 
	            		title='Order', description='Order'),
				},
			)
        ),
	},
	example={
	    "my_order":[{"id":3574,"order":1}, {"id":3573,"order":2}]
	}
)

stream_like_response = {
    '200': """{
		"status_code": 201,
		"data": {
		    "stream": 211,
		    "status": 1,
		    "total_liked": 1,
		    "user_liked": [
		        {
		            "user_image": "https://s3.amazonaws.com/emogo-v2/testing/B6641A9A-F8FB-49FD-ABF5-41E9549D30DC.png",
		            "display_name": "Jonathan Woods",
		            "user_profile_id": 12,
		            "is_following": true,
		            "full_name": "jon",
		            "id": 12
		        }
		    ]
		}
	}""",
}

extremist_report_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['user_comment', 'type'],
    properties={
        'user_comment': openapi.Schema(type=openapi.TYPE_STRING, 
                title='User Comment', maxLength=60, minLength=1,
                description='User Comment'),
        'type': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Type', maxLength=60, minLength=1,
                description='Type')
    },
    example=  {
        "user_comment":"test",
        "type":"Inappropriate"
	}
)

folder_schema_doc = openapi.Schema(
    type=openapi.TYPE_OBJECT, required=['name'],
    properties={
        'name': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Name', maxLength=60, minLength=1),
        'icon': openapi.Schema(type=openapi.TYPE_STRING, 
                title='Icon', maxLength=60, minLength=1)
    },
    example=  {
        "name": "test folder1", "icon": ":)"
	}
)

move_emogo_to_folder_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['folder'],
    properties={
		"folder": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    )
	},
	example={
	    "folder": [29]
	}
)

share_imessage_schema = openapi.Schema(
	type=openapi.TYPE_OBJECT,
    required=['content'],
    properties={
		"content": openapi.Schema(
			type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_INTEGER)
	    )
	},
	example={
	    "content": [29]
	}
)