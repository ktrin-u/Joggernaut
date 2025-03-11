from oauth2_provider.contrib.rest_framework import TokenHasScope

from drf_spectacular.utils import extend_schema

from django.contrib.auth import get_user_model

from rest_framework import views, status
from rest_framework.generics import GenericAPIView
from rest_framework.response import Response
from rest_framework.request import Request

from api.models import User
from api.schema_docs import Tags
from api.permissions import isBanned
from api.helper import get_user_object, clean_request_data
from api.serializers.user import UserModelSerializer, UserDeleteSerializer, UpdateUserPasswordSerializer


@extend_schema(
    summary="Change user password",
    tags=[Tags.USER],
)
class UpdateUserPasswordView(GenericAPIView):
    model = get_user_model()
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]
    serializer_class = UpdateUserPasswordSerializer

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
        serialized = self.get_serializer(data=request.data)  # type: ignore
        if serialized.is_valid():
            serialized.update(instance=user, validated_data=serialized.validated_data)
            return Response(
                {
                    "msg": f"{user.email}'s password has been changed",
                },
                status=status.HTTP_200_OK
            )

        return Response(
            data=serialized.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


class AbstractUserView(views.APIView):
    serializer_class = UserModelSerializer
    model = User
    permission_classes = [isBanned, TokenHasScope]
    required_scopes = []


@extend_schema(
    summary="View user info",
    tags=[Tags.USER],
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

        serialized = self.serializer_class(user)
        return Response(
            data=serialized.data,
            status=status.HTTP_200_OK
        )


@extend_schema(
    summary="Update user info",
    tags=[Tags.USER],
)
class UpdateUserInfoView(AbstractUserView):
    required_scopes = ["write"]

    @extend_schema(
        description="Update the associated entry in the User table. Expects all User Profile fields. This uses the Authentication Token as the identifier."
    )
    def put(self, request) -> Response:
        serialized = UserModelSerializer(get_user_object(request), data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response(status=status.HTTP_202_ACCEPTED)
        return Response(data=serialized.errors, status=status.HTTP_409_CONFLICT)

    @extend_schema(
        description="Update the associated entry in the User table. Does not require all fields. This uses the Authentication Token as the identifier"
    )
    def patch(self, request) -> Response:
        serialized = UserModelSerializer(get_user_object(request), data=clean_request_data(request), partial=True)
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


@extend_schema(
    summary="Delete user account",
    tags=[Tags.USER],
)
class DeleteUserView(AbstractUserView):
    serializer_class = UserDeleteSerializer
    required_scopes = ["write"]

    def get_object(self) -> User | None:
        return get_user_object(self.request)

    @extend_schema(
        description="Expect two matching booleans. The Authentication Token is used as the identifier"
    )
    def post(self, request: Request) -> Response:
        serialized = self.serializer_class(data=request.data)

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
