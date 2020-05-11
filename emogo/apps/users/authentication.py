import rest_framework.authentication
 
from emogo.apps.users.models import Token
 
 
class TokenAuthentication(rest_framework.authentication.TokenAuthentication):
    model = Token