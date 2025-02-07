from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.request import Request


# Create your views here.
@api_view(['GET'])
def Api_overview(request: Request) -> Response:
    return Response(
        {"msg": "Welcome"}
    )
