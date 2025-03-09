from rest_framework.generics import CreateAPIView, GenericAPIView
from oauth2_provider.contrib.rest_framework import TokenHasScope
from drf_spectacular.utils import extend_schema, OpenApiResponse, OpenApiExample
from oauth2_provider.views import TokenView, RevokeTokenView
from django.contrib.auth import get_user_model
from django.core.exceptions import ObjectDoesNotExist
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import permissions, views
from .models import UserProfiles, User, FriendTable
from .permissions import isBanned
from rest_framework import status
from typing import Any
from . import serializers as custom_serializers, schema_docs
from .schema_docs import Tags
from django.db.models import Q
from .helper import get_user_object
from copy import deepcopy


def clean_request_data(request: Request) -> dict[str, Any]:
    """
    Function that removes empty values in the request data
    """
    return {k: v for k, v in request.data.items() if v != ""}  # filter all empty values


RESPONSE_USER_NOT_FOUND = Response(
    {
        "msg": "failed to identify user from auth token",
    },
    status=status.HTTP_404_NOT_FOUND,
)


@extend_schema(
    summary="Register new user account",
    tags=[Tags.AUTH],
)
class CreateUserView(CreateAPIView):
    model = get_user_model()
    permission_classes = [
        permissions.AllowAny  # Or anon users can't register
    ]
    serializer_class = custom_serializers.RegisterFormSerializer


@extend_schema(
    summary="Change user password",
    tags=[Tags.USER],
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
    serializer_class = custom_serializers.UserModelSerializer
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
        serialized = custom_serializers.UserModelSerializer(get_user_object(request), data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response(status=status.HTTP_202_ACCEPTED)
        return Response(data=serialized.errors, status=status.HTTP_409_CONFLICT)

    @extend_schema(
        description="Update the associated entry in the User table. Does not require all fields. This uses the Authentication Token as the identifier"
    )
    def patch(self, request) -> Response:
        serialized = custom_serializers.UserModelSerializer(get_user_object(request), data=clean_request_data(request), partial=True)
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
    summary="View user profile",
    tags=[Tags.PROFILE],
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
    summary="Create new user profile",
    tags=[Tags.PROFILE],
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
    summary="Update user profile",
    tags=[Tags.PROFILE],
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
    summary="Delete user account",
    tags=[Tags.USER],
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


@extend_schema(
    summary="Alternative to /api/auth/token/",
    tags=[Tags.AUTH],
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
    summary="Alternative to /api/auth/revoke_token/",
    tags=[Tags.AUTH],
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
    summary="Ban a user",
    tags=[Tags.ADMIN],
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
    summary="Unban a user",
    tags=[Tags.ADMIN],
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
                "200": f"{user.userid} has been unbanned"  # type: ignore
            },
            status=status.HTTP_200_OK
        )


class AbstractFriendTableView(GenericAPIView):
    model = FriendTable
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]


@extend_schema(
    summary="Create a pending friend request",
    tags=[Tags.FRIENDS],
)
class SendFriendRequestView(AbstractFriendTableView):
    serializer_class = custom_serializers.CreateFriendSerializer

    RESPONSE_SUCCESS = Response(
        {
            "msg": "friend request entry successfully added to database"
        },
        status=status.HTTP_201_CREATED,
    )

    @extend_schema(
        description="Create an entry in the database with status as PENDING. The fromUserId field will be populated with  the user identified by the Auth Token",
        request=custom_serializers.ToUserIdSerializer,
        responses={
            RESPONSE_SUCCESS.status_code: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="success",
                        value=RESPONSE_SUCCESS.data,
                        status_codes=[RESPONSE_SUCCESS.status_code]
                    ),
                ]
            ),
            RESPONSE_USER_NOT_FOUND.status_code: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="user not found",
                        value=RESPONSE_USER_NOT_FOUND.data,
                        status_codes=[RESPONSE_USER_NOT_FOUND.status_code]
                    )
                ]
            )
        }
    )
    def post(self, request: Request) -> Response:
        user = get_user_object(request)

        if user is None:
            return RESPONSE_USER_NOT_FOUND

        data = deepcopy(request.data)
        data["fromUserid"] = user.userid

        serialized = self.get_serializer(data=data)

        if serialized.is_valid():
            serialized.save()
            return self.RESPONSE_SUCCESS

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Accept pending friend request",
    tags=[Tags.FRIENDS],
)
class AcceptFriendView(AbstractFriendTableView):
    serializer_class = custom_serializers.ToUserIdSerializer

    @extend_schema(
        description="Accept a pending request from the specified uuid",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="accepted",
                        value={"msg": "fe316ad8-ccb4-48b7-823e-dab928ee3333 has accepted 3317d233-1d9e-4b75-b521-d9dc73b831c0's request"}
                    )
                ],
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="not found",
                        value={
                            "msg": "No pending friend request from 6460710d-33c0-4c41-81f1-8a21b03b15e1 found."
                        }
                    )
                ]
            ),
            status.HTTP_400_BAD_REQUEST: schema_docs.Response.SERIALIZER_VALIDTION_ERRORS,
        }
    )
    def patch(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            fromUserid = serialized.validated_data["fromUserid"]
            try:
                friend_entry = self.model.objects.get(fromUserid=fromUserid, toUserid=user)

                friend_entry.status = FriendTable.FriendshipStatus.ACCEPTED
                friend_entry.save()
                return Response(
                    {
                        "msg": f"{user.userid} has accepted {fromUserid}'s request"
                    },
                    status=status.HTTP_200_OK
                )

            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"No pending friend request from {fromUserid} found."
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Reject pending friend request",
    tags=[Tags.FRIENDS],
)
class RejectFriendView(AbstractFriendTableView):
    serializer_class = custom_serializers.ToUserIdSerializer

    @extend_schema(
        description="Reject a pending request from the specified uuid",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="accepted",
                        value={"msg": "fe316ad8-ccb4-48b7-823e-dab928ee3333 has rejected 3317d233-1d9e-4b75-b521-d9dc73b831c0's request"}
                    )
                ],
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="not found",
                        value={
                            "msg": "No pending friend request from 6460710d-33c0-4c41-81f1-8a21b03b15e1 found."
                        }
                    )
                ]
            ),
            status.HTTP_400_BAD_REQUEST: schema_docs.Response.SERIALIZER_VALIDTION_ERRORS
        }
    )
    def patch(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            fromUserid = serialized.validated_data["fromUserid"]
            try:
                friend_entry = self.model.objects.get(fromUserid=fromUserid, toUserid=user)
                friend_entry.delete()

                return Response(
                    {
                        "msg": f"{user.userid} has rejected {fromUserid}'s request. Friend Entry deleted."
                    },
                    status=status.HTTP_200_OK
                )

            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"No friend request from {fromUserid} found."
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Get list of friends",
    tags=[Tags.FRIENDS],
)
class GetFriendsView(AbstractFriendTableView):
    serializer_class = custom_serializers.FriendTableSerializer
    required_scopes = ["read"]

    @extend_schema(
        description="Get all the friend entries for the user. It is separated between sent by the user and received by the user.",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=custom_serializers.FriendsListResponseSerializer,
                examples=[
                    OpenApiExample(
                        name="no friends",
                        description="user has no friend entries",
                        value={"sent": [], "received": []}
                    ),
                    OpenApiExample(
                        name="has friends",
                        description="user has friend entries",
                        value={
                            "sent": [
                                {
                                    "friendid": 8,
                                    "fromUserid": "6e0e71b1-f1cc-11ef-bcfe-06ec480f10f7",
                                    "toUserid": "8ba815b6-f1cc-11ef-bcfe-03ec478f12f7",
                                    "status": "PEN",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09"
                                },
                                {
                                    "friendid": 34,
                                    "fromUserid": "6e0e72b1-f2cc-11ef-bcfe-011ec8014f7",
                                    "toUserid": "728218a2-09dc-40c7-93f3-1f2a45c7824c",
                                    "status": "PEN",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09"
                                }
                            ],
                            "received": [
                                {
                                    "friendid": 15,
                                    "fromUserid": "43c18bc0-64d3-4d1e-8055-c797bbed13f4",
                                    "toUserid": "6e0e71d1-f1xc-11ef-bcfe-06ec480f12f7",
                                    "status": "PEN",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09"
                                }
                            ]
                        }
                    )
                ]
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=custom_serializers.MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="user not found",
                        description="failed to identify user based on auth token",
                        value=RESPONSE_USER_NOT_FOUND.data,
                    )
                ]
            )
        }
    )
    def get(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        received = self.get_serializer(
            self.model.objects.filter(toUserid=user),
            many=True
        )

        sent = self.get_serializer(
            self.model.objects.filter(fromUserid=user),
            many=True
        )

        return Response(
            {
                "sent": sent.data,
                "received": received.data,
            },
            status=status.HTTP_200_OK
        )
        ...
