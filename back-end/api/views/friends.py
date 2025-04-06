from copy import deepcopy

from django.core.exceptions import ObjectDoesNotExist
from django.db.models import Q
from drf_spectacular.utils import OpenApiExample, OpenApiResponse, extend_schema
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api import schema_docs
from api.models import FriendTable, User
from api.responses import RESPONSE_USER_NOT_FOUND
from api.schema_docs import Tags
from api.serializers.friends import (
    CreateFriendSerializer,
    FriendsListResponseSerializer,
    FriendTableSerializer,
    FromUserIdSerializer,
    PendingFriendsListResponseSerializer,
    ToUserIdSerializer,
)
from api.serializers.general import MsgSerializer, TargetUserIdSerializer


class AbstractFriendTableView(GenericAPIView):
    model = FriendTable
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]


@extend_schema(
    summary="Create a pending friend request",
    tags=[Tags.FRIENDS],
)
class SendFriendRequestView(AbstractFriendTableView):
    serializer_class = CreateFriendSerializer

    RESPONSE_SUCCESS = Response(
        {"msg": "friend request entry successfully added to database"},
        status=status.HTTP_201_CREATED,
    )

    @extend_schema(
        description="Create an entry in the database with status as PENDING. The fromUserId field will be populated with  the user identified by the Auth Token",
        request=ToUserIdSerializer,
        responses={
            RESPONSE_SUCCESS.status_code: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="success",
                        value=RESPONSE_SUCCESS.data,
                        status_codes=[RESPONSE_SUCCESS.status_code],
                    ),
                ],
            ),
            RESPONSE_USER_NOT_FOUND.status_code: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="user not found",
                        value=RESPONSE_USER_NOT_FOUND.data,
                        status_codes=[RESPONSE_USER_NOT_FOUND.status_code],
                    )
                ],
            ),
        },
    )
    def post(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

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
    serializer_class = FromUserIdSerializer

    @extend_schema(
        description="Accept a pending request from the specified uuid",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="accepted",
                        value={
                            "msg": "fe316ad8-ccb4-48b7-823e-dab928ee3333 has accepted 3317d233-1d9e-4b75-b521-d9dc73b831c0's request"
                        },
                    )
                ],
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="not found",
                        value={
                            "msg": "No pending friend request from 6460710d-33c0-4c41-81f1-8a21b03b15e1 found."
                        },
                    )
                ],
            ),
            status.HTTP_400_BAD_REQUEST: schema_docs.Response.SERIALIZER_VALIDATION_ERRORS,
        },
    )
    def patch(self, request: Request) -> Response:
        user = request.user

        assert isinstance(user, User)

        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        fromUserid = serialized.validated_data["fromUserid"]
        try:
            friend_entry = self.model.objects.get(
                fromUserid=fromUserid,
                toUserid=user.userid,
                status=FriendTable.FriendshipStatus.PENDING,
            )

            friend_entry.status = FriendTable.FriendshipStatus.ACCEPTED
            friend_entry.save()
            return Response(
                {"msg": f"{user.userid} has accepted {fromUserid}'s request"},
                status=status.HTTP_200_OK,
            )

        except ObjectDoesNotExist:
            return Response(
                {"msg": f"No pending friend request from {fromUserid} found."},
                status=status.HTTP_404_NOT_FOUND,
            )


@extend_schema(
    summary="Reject pending friend request",
    tags=[Tags.FRIENDS],
)
class RejectFriendView(AbstractFriendTableView):
    serializer_class = FromUserIdSerializer

    @extend_schema(
        description="Reject a pending request from the specified uuid",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="accepted",
                        value={
                            "msg": "fe316ad8-ccb4-48b7-823e-dab928ee3333 has rejected 3317d233-1d9e-4b75-b521-d9dc73b831c0's request"
                        },
                    )
                ],
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="not found",
                        value={
                            "msg": "No pending friend request from 6460710d-33c0-4c41-81f1-8a21b03b15e1 found."
                        },
                    )
                ],
            ),
            status.HTTP_400_BAD_REQUEST: MsgSerializer,
        },
    )
    def patch(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

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
                    status=status.HTTP_200_OK,
                )

            except ObjectDoesNotExist:
                return Response(
                    {"msg": f"No friend request from {fromUserid} found."},
                    status=status.HTTP_404_NOT_FOUND,
                )
        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(summary="Cancel sent pending friend request", tags=[Tags.FRIENDS])
class CancelPendingFriendView(AbstractFriendTableView):
    serializer_class = ToUserIdSerializer

    @extend_schema(description="Cancel a sent friend request which is still pending")
    def patch(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            toUserid = serialized.validated_data["toUserid"]
            try:
                friend_entry = self.model.objects.get(
                    toUserid=toUserid,
                    fromUserid=user.userid,
                    status=FriendTable.FriendshipStatus.PENDING,
                )

                friend_entry.delete()
                return Response(
                    {"msg": f"pending request to {toUserid} has been canceled"},
                    status=status.HTTP_200_OK,
                )

            except ObjectDoesNotExist:
                return Response(
                    {"msg": f"No pending friend request to {toUserid} found."},
                    status=status.HTTP_404_NOT_FOUND,
                )
        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Get list of pending friends",
    tags=[Tags.FRIENDS],
)
class GetPendingFriendsView(AbstractFriendTableView):
    serializer_class = FriendTableSerializer
    required_scopes = ["read"]

    @extend_schema(
        description="Get all the pending friend entries for the user. It is separated between sent by the user and received by the user.",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=PendingFriendsListResponseSerializer,
                examples=[
                    OpenApiExample(
                        name="no friends",
                        description="user has no friend entries",
                        value={"sent": [], "received": []},
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
                                    "lastUpdate": "2025-03-09",
                                },
                                {
                                    "friendid": 34,
                                    "fromUserid": "6e0e72b1-f2cc-11ef-bcfe-011ec8014f7",
                                    "toUserid": "728218a2-09dc-40c7-93f3-1f2a45c7824c",
                                    "status": "PEN",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09",
                                },
                            ],
                            "received": [
                                {
                                    "friendid": 15,
                                    "fromUserid": "43c18bc0-64d3-4d1e-8055-c797bbed13f4",
                                    "toUserid": "6e0e71d1-f1xc-11ef-bcfe-06ec480f12f7",
                                    "status": "PEN",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09",
                                }
                            ],
                        },
                    ),
                ],
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="user not found",
                        description="failed to identify user based on auth token",
                        value=RESPONSE_USER_NOT_FOUND.data,
                    )
                ],
            ),
        },
    )
    def get(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        received = self.get_serializer(
            self.model.objects.filter(toUserid=user, status=FriendTable.FriendshipStatus.PENDING),
            many=True,
        )

        sent = self.get_serializer(
            self.model.objects.filter(fromUserid=user, status=FriendTable.FriendshipStatus.PENDING),
            many=True,
        )

        return Response(
            {
                "sent": sent.data,
                "received": received.data,
            },
            status=status.HTTP_200_OK,
        )


@extend_schema(
    summary="Get list of friends",
    tags=[Tags.FRIENDS],
)
class GetFriendsView(AbstractFriendTableView):
    serializer_class = FriendTableSerializer
    required_scopes = ["read"]

    @extend_schema(
        description="Get all the friends of the user identified by the auth token whose status is accepted",
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=FriendsListResponseSerializer,
                description="sucessfully acquired user friend list",
                examples=[
                    OpenApiExample(
                        name="no friends",
                        description="user has no friend entries",
                        value={"friends:[]"},
                    ),
                    OpenApiExample(
                        name="has friends",
                        description="user has friend entries",
                        value={
                            "friends": [
                                {
                                    "friendid": 8,
                                    "fromUserid": "6e0e71b1-f1cc-11ef-bcfe-06ec480f10f7",
                                    "toUserid": "8ba815b6-f1cc-11ef-bcfe-03ec478f12f7",
                                    "status": "ACC",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09",
                                },
                                {
                                    "friendid": 34,
                                    "fromUserid": "6e0e72b1-f2cc-11ef-bcfe-011ec8014f7",
                                    "toUserid": "728218a2-09dc-40c7-93f3-1f2a45c7824c",
                                    "status": "ACC",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09",
                                },
                                {
                                    "friendid": 15,
                                    "fromUserid": "43c18bc0-64d3-4d1e-8055-c797bbed13f4",
                                    "toUserid": "6e0e71d1-f1xc-11ef-bcfe-06ec480f12f7",
                                    "status": "ACC",
                                    "creationDate": "2025-03-09",
                                    "lastUpdate": "2025-03-09",
                                },
                            ]
                        },
                    ),
                ],
            ),
            status.HTTP_404_NOT_FOUND: schema_docs.Response.AUTH_TOKEN_USER_NOT_FOUND,
        },
    )
    def get(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        friends = self.get_serializer(
            self.model.objects.filter(
                Q(toUserid=user, status=FriendTable.FriendshipStatus.ACCEPTED)
                | Q(fromUserid=user, status=FriendTable.FriendshipStatus.ACCEPTED)
            ),
            many=True,
        )

        return Response(
            {
                "friends": friends.data,
            },
            status=status.HTTP_200_OK,
        )


@extend_schema(summary="Unfriend a friend", tags=[Tags.FRIENDS])
class RemoveFriendView(AbstractFriendTableView):
    serializer_class = TargetUserIdSerializer

    @extend_schema(description="Find the friendship entry with the given userid and then delete it")
    def post(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            targetUserid = serialized.validated_data["targetid"]
            # Use filter() to handle multiple entries
            entries = FriendTable.objects.filter(
                Q(fromUserid=targetUserid, toUserid=user.userid)
                | Q(toUserid=targetUserid, fromUserid=user.userid)
            )
            if entries.exists():
                entries.delete()
                return Response(
                    {"msg": f"successfully unfriended {targetUserid}"},
                    status=status.HTTP_200_OK,
                )
            return Response(
                {"msg": f"unable to find friendship entry with {targetUserid}"},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)
