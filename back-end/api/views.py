from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import permissions
from rest_framework import status
from rest_framework.generics import CreateAPIView, GenericAPIView, RetrieveUpdateAPIView
from .models import UserProfiles, User
from django.contrib.auth import get_user_model
from oauth2_provider.contrib.rest_framework import TokenHasScope
from oauth2_provider.models import AccessToken
from .serializers import RegisterFormSerializer, UserProfileFormSerializer, UserModelSerializer
from typing import Any


def get_token_from_header(request: Request) -> tuple[str, str]:
    """
    This function gets the token type and token from the Authorization header.
    It returns in the form (token_type, token)
    """
    authorization_header = request.headers.get("Authorization")

    if authorization_header is not None:
        split_header = authorization_header.split(" ")
        if len(split_header) != 2:
            return ("", "")
        return tuple(split_header)  # type: ignore

    return ("", "")


def get_user_from_token(token: str) -> User | None:
    """
    This function gets the corresponding User object associated with the provided token
    """
    try:
        access_token: AccessToken = AccessToken.objects.get(token=token)

        user: User = User.objects.get(email=access_token.user)

        return user

    except AccessToken.DoesNotExist:
        return None
    except User.DoesNotExist:
        return None


def get_user_object(request: Request) -> User | None:
    """
    Wrapper function which combines get_user_from_token and get_token_from_header
    """
    _, token = get_token_from_header(request)
    return get_user_from_token(token)


class CreateUserView(CreateAPIView):
    model = get_user_model()
    permission_classes = [
        permissions.AllowAny  # Or anon users can't register
    ]
    serializer_class = RegisterFormSerializer


class UserView(RetrieveUpdateAPIView):
    serializer_class = UserModelSerializer
    model = get_user_model()
    permission_classes = [TokenHasScope]
    required_scopes = ["read", "write"]

    def get_object(self):
        return get_user_object(self.request)

    def get(self, request: Request, format=None) -> Response:
        user = get_user_object(request)

        if user is None:
            return Response(
                {
                    "msg": "Failed to retrieve corresponding user"
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        serialized = self.get_serializer_class()(user)
        return Response(
            data=serialized.data,
            status=status.HTTP_200_OK
        )

    def clean_request_data(self, request: Request) -> dict[str, Any]:
        return {k: v for k, v in request.data.items() if v != ""}  # filter all empty values

    def put(self, request) -> Response:
        serialized = UserModelSerializer(self.get_object(), data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response(status=status.HTTP_202_ACCEPTED)
        return Response(data=serialized.errors, status=status.HTTP_409_CONFLICT)

    def patch(self, request) -> Response:
        serialized = UserModelSerializer(self.get_object(), data=self.clean_request_data(request), partial=True)
        if serialized.is_valid():
            serialized.save()
            return Response(
                data=serialized.data,
                status=status.HTTP_202_ACCEPTED
            )

        return Response(
            data=serialized.error_messages,
            status=status.HTTP_409_CONFLICT
        )


class UserProfileView(GenericAPIView):
    serializer_class = UserProfileFormSerializer
    model = UserProfiles
    permission_classes = [TokenHasScope]
    required_scopes = ["read", "write"]

    def get(self, request: Request, format=None) -> Response:
        user = get_user_object(request)
        if user is None:
            return Response(
                {
                    "msg": "unable to find user"
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            profile = self.model.objects.get(userid=user.userid)
            serializer = self.get_serializer_class()(profile)
            return Response(
                data=serializer.data,
                status=status.HTTP_200_OK
            )
        except UserProfiles.DoesNotExist:
            return Response(
                {
                    "msg": "User profile does not exist"
                },
                status=status.HTTP_404_NOT_FOUND
            )

    def post(self, request: Request, format=None) -> Response:
        serialized = UserProfileFormSerializer(data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response({
                "msg": "user profile created"
            }, status=status.HTTP_201_CREATED)

        return Response(
            data=serialized.errors,
            status=status.HTTP_406_NOT_ACCEPTABLE
        )
