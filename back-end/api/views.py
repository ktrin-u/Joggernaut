from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import permissions
from rest_framework import status
from rest_framework.generics import CreateAPIView
from .models import User
from django.core.validators import validate_email
from django.contrib.auth import get_user_model
from .validators import validate_phoneNumber
from .serializers import RegisterFormSerializer


# Create your views here.
@api_view(['GET'])
def Api_overview(request: Request) -> Response:
    return Response(
        {"msg": "Welcome"}
    )


@api_view(['GET'])
def check_taken_phonenumber(request: Request) -> Response:
    phone = request.query_params.get("phonenumber")

    if phone is None:
        raise ValueError(f"phone number is {phone}")

    validate_phoneNumber(phone)
    registered_phones = User.objects.filter(phonenumber=phone)

    if registered_phones:
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

    validate_email(email)
    registered_emails = User.objects.filter(email=email)

    if registered_emails:
        return Response(
            {"msg": "taken"},
            status=status.HTTP_409_CONFLICT
        )

    return Response(
        {"msg": "valid"},
        status=status.HTTP_200_OK
    )


class CreateUserView(CreateAPIView):
    model = get_user_model()
    permission_classes = [
        permissions.AllowAny  # Or anon users can't register
    ]
    serializer_class = RegisterFormSerializer
