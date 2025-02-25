from rest_framework.generics import CreateAPIView, GenericAPIView
from oauth2_provider.contrib.rest_framework import TokenHasScope
from drf_spectacular.utils import extend_schema
from oauth2_provider.views import TokenView, RevokeTokenView
from django.contrib.auth import get_user_model
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import permissions
from .models import UserProfiles, User
from .permissions import isBanned
from rest_framework import status
from typing import Any
from . import serializers as custom_serializers
from django.db.models import Q
from .helper import get_user_object


def clean_request_data(request: Request) -> dict[str, Any]:
    """
    Function that removes empty values in the request data
    """
    return {k: v for k, v in request.data.items() if v != ""}  # filter all empty values


@extend_schema(
    summary="Register new user account"
)
class CreateUserView(CreateAPIView):
    model = get_user_model()
    permission_classes = [
        permissions.AllowAny  # Or anon users can't register
    ]
    serializer_class = custom_serializers.RegisterFormSerializer


@extend_schema(
    summary="Change user password"
)
class UpdateUserPasswordView(GenericAPIView):
    model = get_user_model()
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]
    serializer_class = custom_serializers.UpdateUserPasswordSerializer

    def get_object(self) -> User | None:
        return get_user_object(self.request)

    @extend_schema(
        description="Supply the password and confirm_password in plaintext. The API will handle hashing and updating the database."
    )
    def patch(self, request: Request) -> Response:
        user = self.get_object()

        if user is None:
            return Response(
                {
                    "msg": "Failed to retrieve corresponding user"
                },
                status=status.HTTP_404_NOT_FOUND
            )
        request_data = clean_request_data(request)
        serialized = self.get_serializer(data=request_data)  # type: ignore
        if serialized.is_valid():
            serialized.update(instance=user, validated_data=serialized.validated_data)
            return Response(
                status=status.HTTP_200_OK
            )

        return Response(
            data=serialized.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


class AbstractUserView(GenericAPIView):
    serializer_class = custom_serializers.UserModelSerializer
    model = get_user_model()
    permission_classes = [isBanned, TokenHasScope]
    required_scopes = []


@extend_schema(
    summary="View user info",
)
class ViewUserInfoView(AbstractUserView):
    required_scopes = ['read']

    def get_object(self):
        return get_user_object(self.request)

    @extend_schema(
        description="Retrieve the associated entry in the User table. This uses the Authentication Token as the identifier."
    )
    def get(self, request: Request, format=None) -> Response:
        user = self.get_object()

        if user is None:
            return Response(
                {
                    "msg": "Failed to retrieve corresponding user"
                },
                status=status.HTTP_404_NOT_FOUND
            )

        serialized = self.get_serializer_class()(user)
        return Response(
            data=serialized.data,
            status=status.HTTP_200_OK
        )


@extend_schema(
    summary="Update user info"
)
class UpdateUserInfoView(AbstractUserView):
    required_scopes = ["write"]

    @extend_schema(
        description="Update the associated entry in the User table. Expects all User Profile fields. This uses the Authentication Token as the identifier."
    )
    def put(self, request) -> Response:
        serialized = custom_serializers.UserModelSerializer(self.get_object(), data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response(status=status.HTTP_202_ACCEPTED)
        return Response(data=serialized.errors, status=status.HTTP_409_CONFLICT)

    @extend_schema(
        description="Update the associated entry in the User table. Does not require all fields. This uses the Authentication Token as the identifier"
    )
    def patch(self, request) -> Response:
        serialized = custom_serializers.UserModelSerializer(self.get_object(), data=clean_request_data(request), partial=True)
        if serialized.is_valid():
            serialized.save()
            return Response(
                data=serialized.data,
                status=status.HTTP_202_ACCEPTED
            )

        return Response(
            data=serialized.errors,
            status=status.HTTP_409_CONFLICT
        )


class AbstractUserProfileView(GenericAPIView):
    serializer_class = custom_serializers.UserProfileFormSerializer
    model = UserProfiles
    permission_classes = [TokenHasScope]
    required_scopes = []


@extend_schema(
    summary="View user profile"
)
class UserProfileView(AbstractUserProfileView):
    required_scopes = ["read"]

    @extend_schema(
        description="Uses the Authentication Token as identifier"
    )
    def get(self, request: Request, format=None) -> Response:
        user = get_user_object(request)
        if user is None:
            return Response(
                {
                    "msg": "unable to find user"
                },
                status=status.HTTP_404_NOT_FOUND
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


@extend_schema(
    summary="Create new user profile"
)
class CreateUserProfileView(AbstractUserProfileView):
    required_scopes = ["write"]

    @extend_schema(
        description="TBA"
    )
    def post(self, request: Request, format=None) -> Response:
        serialized = custom_serializers.UserProfileFormSerializer(data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response({
                "msg": "user profile created"
            }, status=status.HTTP_201_CREATED)

        return Response(
            data=serialized.errors,
            status=status.HTTP_406_NOT_ACCEPTABLE
        )


@extend_schema(
    summary="Update user profile"
)
class UpdateUserProfileView(AbstractUserProfileView):
    required_scopes = ["write"]

    @extend_schema(
        description="Updates the relevant entry in the database. Does not expect all fields. This uses the Authentication Token as the identifier."
    )
    def patch(self, request: Request) -> Response:
        user = get_user_object(request)

        if user is None:
            return Response(
                {
                    "msg": "unable to find user"
                },
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            profile = self.model.objects.get(userid=user.userid)
            serializer = self.get_serializer_class()
            serialized = serializer(instance=profile, data=clean_request_data(request), partial=True)

            if serialized.is_valid():
                serialized.save()
                return Response(
                    data=serialized.data,
                    status=status.HTTP_201_CREATED
                )

            return Response(
                data=serialized.errors,
                status=status.HTTP_406_NOT_ACCEPTABLE
            )

        except UserProfiles.DoesNotExist:
            return Response(
                {
                    "msg": "User profile does not exist"
                },
                status=status.HTTP_404_NOT_FOUND
            )


@extend_schema(
    summary="Delete user account"
)
class DeleteUserView(AbstractUserView):
    serializer_class = custom_serializers.UserDeleteSerializer
    required_scopes = ["write"]

    def get_object(self) -> User | None:
        return get_user_object(self.request)

    @extend_schema(
        description="Expect two matching booleans. The Authentication Token is used as the identifier"
    )
    def post(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            user = self.get_object()

            if user is not None:
                deleted_userid = user.userid
                user.delete()
                return Response(
                    {
                        "msg": f"user {deleted_userid} has been deleted."
                    },
                    status=status.HTTP_200_OK
                )

            return Response(
                {
                    "msg": "user not found"
                },
                status=status.HTTP_404_NOT_FOUND
            )

        return Response(
            data=serialized.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


@extend_schema(
    summary="Alternative to /api/auth/token/"
)
class TokenAPIView(TokenView, GenericAPIView):
    serializer_class = custom_serializers.TokenSerializer
    permission_classes = [isBanned]

    @extend_schema(
        description="For acquiring an access token",
        responses=custom_serializers.TokenResponseSerializer
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


@extend_schema(
    summary="Alternative to /api/auth/revoke_token/"
)
class RevokeTokenAPIView(RevokeTokenView, GenericAPIView):
    serializer_class = custom_serializers.RevokeTokenSerializer
    permission_classes = [isBanned]

    @extend_schema(
        description="Implements an endpoint to revoke access tokens",
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


class AbstractUpdateUserUserPermissionsView(GenericAPIView):
    serializer_class = custom_serializers.UpdateUserPermissionsSerializer
    permission_classes = [permissions.IsAdminUser, TokenHasScope]
    required_scopes = ["write"]

    def find_target_user(self, request: Request):
        serialized = self.get_serializer(data=request.data)
        if serialized.is_valid():
            email = serialized.validated_data.get("email")
            uuid = serialized.validated_data.get("userid")
            user = get_user_model().objects.filter(Q(email=email) | Q(userid=uuid)).first()

            if user is None:
                return Response(
                    {
                        "msg": "user not found",
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
            return user

        return Response(
            data=serialized.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


@extend_schema(
    summary="Ban a user"
)
class BanUserView(AbstractUpdateUserUserPermissionsView):
    @extend_schema(
        description="Give the userid or email of the user to be banned",
    )
    def post(self, request: Request) -> Response:
        user = self.find_target_user(request)
        if isinstance(user, Response):
            return user

        user.ban()  # type: ignore
        user.save()
        return Response(
            {
                "msg": f"{user.userid} has been banned"  # type: ignore
            },
            status=status.HTTP_200_OK
        )


@extend_schema(
    summary="Unban a user"
)
class UnbanUserView(AbstractUpdateUserUserPermissionsView):
    @extend_schema(
        description="Give the userid or email of the user to be banned",
    )
    def post(self, request: Request) -> Response:
        user = self.find_target_user(request)
        if isinstance(user, Response):
            return user

        user.unban()  # type: ignore
        user.save()
        return Response(
            {
                "msg": f"{user.userid} has been unbanned"  # type: ignore
            },
            status=status.HTTP_200_OK
        )
