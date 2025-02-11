from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import status
from .models import User


# Create your views here.
@api_view(['GET'])
def Api_overview(request: Request) -> Response:
    return Response(
        {"msg": "Welcome"}
    )


@api_view(['GET'])
def check_taken_phonenumber(request: Request) -> Response:
    phone = request.query_params.get("phonenumber")

    registered_phones = User.objects.values_list("phonenumber", flat=True)

    if phone in registered_phones:
        return Response(
            {"msg": "taken"},
            status=status.HTTP_409_CONFLICT
        )

    return Response(
        {"msg": "valid"},
        status=status.HTTP_200_OK
    )


@api_view(['GET'])
def check_taken_email(request: Request) -> Response:
    email = request.query_params.get("email")

    registered_emails = User.objects.values_list("email", flat=True)

    if email in registered_emails:
        return Response(
            {"msg": "taken"},
            status=status.HTTP_409_CONFLICT
        )

    return Response(
        {"msg": "valid"},
        status=status.HTTP_200_OK
    )