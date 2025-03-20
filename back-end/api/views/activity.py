from copy import deepcopy
from datetime import timedelta

from oauth2_provider.contrib.rest_framework import TokenHasScope

from drf_spectacular.utils import extend_schema, OpenApiResponse, OpenApiExample

from django.core.exceptions import ObjectDoesNotExist
from django.utils import timezone
from django.db.models import Q

from rest_framework.generics import GenericAPIView
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import status

from api.schema_docs import Tags, Response as Schema_Response
from api.models import FriendTable, FriendActivity
from api.helper import get_user_object
from api.responses import RESPONSE_USER_NOT_FOUND
from api.serializers.general import MsgSerializer
from api.serializers.activity import (
    FriendActivitySerializer,
    FriendActivityChoices,
    PokeFriendSerializer,
    ChallengeFriendSerializer,
    TargetActivitySerializer,
)


class AbstractActivityView(GenericAPIView):
    model = FriendActivity
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]


@extend_schema(
    summary="View user's activities with friends",
    tags=[Tags.ACTIVITY],
)
class GetFriendActivityView(AbstractActivityView):
    model = FriendActivity
    serializer_class = FriendActivitySerializer
    permission_classes = [TokenHasScope]
    required_scopes = ["read"]

    @extend_schema(
        description="Get a list of activities between the user and friends.",
    )
    def get(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        activities = self.get_serializer(
            FriendActivity.objects.filter(Q(fromUserid=user) | Q(toUserid=user)),
            many=True,
        )

        return Response(
            {"activities": activities.data},
            status=status.HTTP_200_OK,
        )


@extend_schema(
    summary="Create a friend poke entry",
    tags=[Tags.ACTIVITY],
)
class PokeFriendView(AbstractActivityView):
    model = FriendActivity
    serializer_class = PokeFriendSerializer

    RESPONSE_SUCCESS = Response(
        {"msg": "Poke Friend Activity entry successfully added to database"},
        status=status.HTTP_201_CREATED,
    )

    @extend_schema(
        description=f"Create a Friend Activity entry with activity set to {FriendActivityChoices.POKE}",
        request=TargetActivitySerializer,
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
        user = get_user_object(request)

        if user is None:
            return RESPONSE_USER_NOT_FOUND

        data = deepcopy(request.data)
        data["fromUserid"] = user.userid

        serialized = self.get_serializer(data=data)

        if serialized.is_valid():
            try:
                FriendTable.objects.get(
                    Q(
                        fromUserid=serialized.validated_data["fromUserid"],
                        toUserid=serialized.validated_data["toUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    ) |
                    Q(
                        fromUserid=serialized.validated_data["toUserid"],
                        toUserid=serialized.validated_data["fromUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    )
                )

                serialized.save()
            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"user is not friends with {serialized.validated_data["toUserid"]}"
                    }
                )
            return self.RESPONSE_SUCCESS

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(summary="Create a challenge entry", tags=[Tags.ACTIVITY])
class ChallengeFriendView(AbstractActivityView):
    model = FriendActivity
    serializer_class = ChallengeFriendSerializer

    RESPONSE_SUCCESS = Response(
        {"msg": "Challenge Friend Activity entry successfully added to database"},
        status=status.HTTP_201_CREATED,
    )

    @extend_schema(
        description=f"Create a Friend Activity entry with activity set to {FriendActivityChoices.CHALLENGE}",
        request=TargetActivitySerializer,
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
        user = get_user_object(request)

        if user is None:
            return RESPONSE_USER_NOT_FOUND

        data = deepcopy(request.data)
        data["fromUserid"] = user.userid

        serialized = self.get_serializer(data=data)

        if serialized.is_valid():
            try:
                FriendTable.objects.get(
                    Q(
                        fromUserid=serialized.validated_data["fromUserid"],
                        toUserid=serialized.validated_data["toUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    ) |
                    Q(
                        fromUserid=serialized.validated_data["toUserid"],
                        toUserid=serialized.validated_data["fromUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    )
                )

                serialized.save()
            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"user is not friends with {serialized.validated_data["toUserid"]}"
                    }
                )
            return self.RESPONSE_SUCCESS

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Mark an activity as accepted by the recipient", tags=[Tags.ACTIVITY]
)
class AcceptActivityFriendView(AbstractActivityView):
    model = FriendActivity
    serializer_class = TargetActivitySerializer

    @extend_schema(
        description='Set the "accept" field of a FriendActivity entry to True.\n\nFor pokes, this could be ignored or used as an acknowledgement system.\n\nFor challenges, this signifies challenge accepted.',
        request=TargetActivitySerializer,
        responses=MsgSerializer,
    )
    def patch(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            activityid = serialized.validated_data["activityid"]
            try:
                activity = self.model.objects.get(activityid=activityid, toUserid=request.user.userid)  # type: ignore

                delta = timezone.now() - activity.creationDate

                if delta > timedelta(minutes=5):
                    return Response(
                        {
                            "msg": f"Activity {activityid} has already expired",
                        },
                        status=status.HTTP_400_BAD_REQUEST
                    )

                activity.accept_activity()
            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"Activity {activityid} does not exist",
                    },
                    status=status.HTTP_404_NOT_FOUND,
                )
            return Response(
                {"msg": f"Activity {activityid} accept set to True"},
                status=status.HTTP_200_OK,
            )

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Cancel an unaccepted activity", tags=[Tags.ACTIVITY]
)
class CancelActivityView(AbstractActivityView):
    serializer_class = TargetActivitySerializer

    @extend_schema(
        description="Cancel the sent activity identified by activityid and the user auth token by deleting the entry.\n\n Accepted activities cannot be canceled.",
        request=TargetActivitySerializer,
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response=MsgSerializer,
                description="Successful delete",
                examples=[
                    OpenApiExample(name="success", value={"msg": "successfully deleted activity identified by activityid 25 sent by user test@test.com"}),
                ]
            ),
            status.HTTP_404_NOT_FOUND: OpenApiResponse(
                response=MsgSerializer,
                description="no matching activity entry",
                examples=[
                    OpenApiExample(name="not found", value={"msg": "unable to find activity identified by activityid 64 sent by user test@test.com"})
                ]
            ),
            status.HTTP_400_BAD_REQUEST: OpenApiResponse(
                response=MsgSerializer,
                description="bad user input",
                examples=[
                    OpenApiExample(name="already accepted", value={"msg": "cannot delete accepted activity identified by activityid 14 sent by user test@test.com"}),
                    Schema_Response.SERIALIZER_VALIDATION_ERRORS.examples[0]
                ]
            )
        }
    )
    def post(self, request: Request) -> Response:
        serialized = self.get_serializer(request.data)
        if serialized.is_valid():
            activityid = serialized.validated_data["activityid"]
            try:
                activity = self.model.objects.get(activityid=activityid, fromUserid=request.user.userid)  # type: ignore
                if activity.accept:
                    return Response(
                        {
                            "msg": f"cannot delete accepted activity identified by activityid {activityid} sent by user {request.user}"
                        },
                        status=status.HTTP_400_BAD_REQUEST
                    )
                activity.delete()
                return Response(
                    {
                        "msg": f"successfully deleted activity identified by activityid {activityid} sent by user {request.user}"
                    },
                    status=status.HTTP_200_OK
                )

            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"unable to find activity identified by activityid {activityid} sent by user {request.user}",
                    },
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)
