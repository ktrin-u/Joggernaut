from copy import deepcopy

from oauth2_provider.contrib.rest_framework import TokenHasScope

from drf_spectacular.utils import extend_schema, OpenApiResponse, OpenApiExample

from django.core.exceptions import ObjectDoesNotExist
from django.db.models import Q

from rest_framework.generics import GenericAPIView
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import status

from api.schema_docs import Tags
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
        user = get_user_object(request)

        if user is None:
            return RESPONSE_USER_NOT_FOUND

        serialized = self.get_serializer(data=request.data)

        if serialized.is_valid():
            activityid = serialized.validated_data["activityid"]
            try:
                activity = self.model.objects.get(activityid=activityid)

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
