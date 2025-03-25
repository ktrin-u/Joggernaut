from copy import deepcopy

from django.core.exceptions import ObjectDoesNotExist
from django.db.models import Q, QuerySet
from drf_spectacular.utils import (
    OpenApiExample,
    OpenApiParameter,
    OpenApiResponse,
    extend_schema,
)
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api.models import (
    FriendActivity,
    FriendActivityChoices,
    FriendActivityStatus,
    FriendTable,
    User,
)
from api.responses import RESPONSE_USER_NOT_FOUND
from api.schema_docs import Response as Schema_Response
from api.schema_docs import Tags
from api.serializers import (
    CreateActivitySerializer,
    FilterFriendActivitySerializer,
    FriendActivitySerializer,
    MsgSerializer,
    NewActivitySerializer,
    TargetActivitySerializer,
)


@extend_schema(tags=[Tags.ACTIVITY])
class AbstractActivityView(GenericAPIView):
    model = FriendActivity
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]


MSG_PASS = "PASS: set activity {0} status to {1}"
MSG_FAIL = "FAIL: activity {0} status is {1}"


@extend_schema(
    summary="View user's activities with friends",
    tags=[Tags.ACTIVITY],
)
class GetFriendActivityView(AbstractActivityView):
    serializer_class = FriendActivitySerializer
    required_scopes = ["read"]

    SCHEMA_PARAMETERS = [
        OpenApiParameter(
            name=activity_status.name,
            type=bool,
            location=OpenApiParameter.QUERY,
            required=False,
            description=f"Include activities whose status is set to {activity_status}. Defaults to True if left blank.",
        )
        for activity_status in FriendActivityStatus
    ]

    SCHEMA_RESPONSES = {
        status.HTTP_200_OK: OpenApiResponse(
            response=FilterFriendActivitySerializer,
            description="filtered list of activities",
            examples=[
                OpenApiExample(
                    name="has activities",
                    value={
                        "activities": [
                            {
                                "activityid": 15,
                                "fromUserid": "6e0e71b1-f1cc-11ef-bcfe-06ec483f12f7",
                                "toUserid": "8ba818b6-f1cc-11ef-bcfe-06ec484f12f7",
                                "activity": "POK",
                                "status": "PEN",
                                "statusDate": "null",
                                "durationSecs": 3600,
                                "creationDate": "2025-03-18T13:48:51.597902+08:00",
                            },
                            {
                                "activityid": 16,
                                "fromUserid": "6e0e71b1-f1cc-11ef-bcfe-06ec482f12f7",
                                "toUserid": "8ba818b6-f1cc-11ef-bcfe-06ec483f12f7",
                                "activity": "CHA",
                                "status": "PEN",
                                "statusDate": "null",
                                "durationSecs": 3600,
                                "creationDate": "2025-03-18T13:51:16.332462+08:00",
                            },
                            {
                                "activityid": 20,
                                "fromUserid": "43c18bc0-6467-4b1e-8055-c797bbed13f4",
                                "toUserid": "6e0e71b1-f5cc-11ef-bcfe-06ec480f12f7",
                                "activity": "CHA",
                                "status": "PEN",
                                "statusDate": "null",
                                "durationSecs": 3600,
                                "creationDate": "2025-03-19T17:41:54.995676+08:00",
                            },
                        ],
                    },
                ),
                OpenApiExample(name="no activities", value={"activities": []}),
            ],
        ),
    }

    @extend_schema(
        description="Get a list of activities between the user and friends\n\n The query params can be used to filter the results.",
        parameters=SCHEMA_PARAMETERS,
        responses=SCHEMA_RESPONSES,
    )
    def get(self, request: Request) -> Response:
        user = request.user

        serialized = FilterFriendActivitySerializer(data=request.query_params)

        if not serialized.is_valid():
            return Response(serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        activities_qset: QuerySet[FriendActivity] = FriendActivity.objects.filter(
            Q(fromUserid=user) | Q(toUserid=user)
        )

        for activity_status in FriendActivityStatus:
            if not serialized.validated_data[activity_status.name]:
                activities_qset = activities_qset.exclude(status=activity_status)

        for activity in activities_qset:
            _ = activity.expired  # update status if expired

        activities = self.get_serializer(
            activities_qset,
            many=True,
        )

        return Response(
            activities.data,
            status=status.HTTP_200_OK,
        )


@extend_schema(
    summary="Create a friend poke entry",
    tags=[Tags.ACTIVITY],
)
class PokeFriendView(AbstractActivityView):
    model = FriendActivity
    serializer_class = CreateActivitySerializer

    RESPONSE_SUCCESS = Response(
        {"msg": "Poke Friend Activity entry successfully added to database"},
        status=status.HTTP_201_CREATED,
    )

    @extend_schema(
        description=f"Create a Friend Activity entry with activity set to {FriendActivityChoices.POKE}",
        request=NewActivitySerializer,
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
        assert isinstance(request.user, User)
        data = deepcopy(request.data)
        data["fromUserid"] = request.user.userid

        serialized = self.get_serializer(data=data)

        if serialized.is_valid():
            try:
                FriendTable.objects.get(
                    Q(
                        fromUserid=serialized.validated_data["fromUserid"],
                        toUserid=serialized.validated_data["toUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    )
                    | Q(
                        fromUserid=serialized.validated_data["toUserid"],
                        toUserid=serialized.validated_data["fromUserid"],
                        status=FriendTable.FriendshipStatus.ACCEPTED,
                    )
                )
                serialized.save(activity_type=FriendActivityChoices.POKE)
            except ObjectDoesNotExist:
                return Response(
                    {
                        "msg": f"user is not friends with {serialized.validated_data['toUserid']}"
                    }
                )
            return self.RESPONSE_SUCCESS

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)


@extend_schema(summary="Create a challenge entry", tags=[Tags.ACTIVITY])
class ChallengeFriendView(AbstractActivityView):
    model = FriendActivity
    serializer_class = CreateActivitySerializer

    RESPONSE_SUCCESS = Response(
        {"msg": "Challenge Friend Activity entry successfully added to database"},
        status=status.HTTP_201_CREATED,
    )

    SCHEMA_RESPONSES = {
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
    }

    @extend_schema(
        description=f"Create a Friend Activity entry with activity set to {FriendActivityChoices.CHALLENGE}",
        request=NewActivitySerializer,
        responses=SCHEMA_RESPONSES,
    )
    def post(self, request: Request) -> Response:
        assert isinstance(request.user, User)

        data = deepcopy(request.data)
        data["fromUserid"] = request.user.userid

        serialized = self.get_serializer(data=data)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)
        try:
            FriendTable.objects.get(
                Q(
                    fromUserid=serialized.validated_data["fromUserid"],
                    toUserid=serialized.validated_data["toUserid"],
                    status=FriendTable.FriendshipStatus.ACCEPTED,
                )
                | Q(
                    fromUserid=serialized.validated_data["toUserid"],
                    toUserid=serialized.validated_data["fromUserid"],
                    status=FriendTable.FriendshipStatus.ACCEPTED,
                )
            )
            serialized.save(activity_type=FriendActivityChoices.CHALLENGE)
        except ObjectDoesNotExist:
            return Response(
                {
                    "msg": f"user is not friends with {serialized.validated_data['toUserid']}"
                }
            )
        return self.RESPONSE_SUCCESS


@extend_schema(summary="Accept a pending received activity", tags=[Tags.ACTIVITY])
class AcceptActivityFriendView(AbstractActivityView):
    serializer_class = TargetActivitySerializer

    SCHEMA_RESPONSES = {
        status.HTTP_200_OK: OpenApiResponse(
            response=MsgSerializer,
            examples=[
                OpenApiExample(
                    name="ACCEPT",
                    value={"msg": MSG_PASS.format(12, FriendActivityStatus.ACCEPT)},
                )
            ],
        ),
        status.HTTP_400_BAD_REQUEST: OpenApiResponse(
            response=MsgSerializer,
            examples=[
                OpenApiExample(
                    name=activity_status.name,
                    value={"msg": MSG_FAIL.format(32, activity_status)},
                )
                for activity_status in FriendActivityStatus
                if activity_status != FriendActivityStatus.ACCEPT
            ],
        ),
        status.HTTP_404_NOT_FOUND: OpenApiResponse(
            response=MsgSerializer,
            examples=[
                OpenApiExample(
                    name="NOT FOUND",
                    value={"msg": MSG_FAIL.format(54, "NOT FOUND")},
                )
            ],
        ),
    }

    @extend_schema(
        description=f"Accept a received activity identified by activityid and the user auth token by setting its status to {FriendActivityStatus.ACCEPT}.\n\n Only pending activities can be accepted.",
        request=TargetActivitySerializer,
        responses=SCHEMA_RESPONSES,
    )
    def patch(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        activityid = serialized.validated_data["activityid"]
        try:
            activity = self.model.objects.get(
                activityid=activityid,
                toUserid=request.user.userid,  # type: ignore
            )  # type: ignore

            if (
                activity.status == FriendActivityStatus.PENDING
                and activity.accept_activity()
            ):
                return Response(
                    {"msg": MSG_PASS.format(activityid, FriendActivityStatus.ACCEPT)},
                    status=status.HTTP_200_OK,
                )

            return Response(
                {"msg": MSG_FAIL.format(activityid, activity.status)},
                status=status.HTTP_400_BAD_REQUEST,
            )

        except ObjectDoesNotExist:
            return Response(
                {
                    "msg": MSG_FAIL.format(activityid, "NOT FOUND"),
                },
                status=status.HTTP_404_NOT_FOUND,
            )


@extend_schema(summary="Cancel a pending sent activity", tags=[Tags.ACTIVITY])
class CancelActivityView(AbstractActivityView):
    serializer_class = TargetActivitySerializer

    RESPONSES = {
        status.HTTP_200_OK: OpenApiResponse(
            response=MsgSerializer,
            description="successful delete",
            examples=[
                OpenApiExample(
                    name="success",
                    value={
                        "msg": MSG_PASS.format(13, FriendActivityStatus.CANCEL),
                    },
                ),
            ],
        ),
        status.HTTP_404_NOT_FOUND: OpenApiResponse(
            response=MsgSerializer,
            description="no matching activity entry",
            examples=[
                OpenApiExample(
                    name="not found",
                    value={"msg": MSG_FAIL.format(15, "NOT FOUND")},
                )
            ],
        ),
        status.HTTP_400_BAD_REQUEST: OpenApiResponse(
            response=MsgSerializer,
            description="attempt to cancel a non pending activity",
            examples=[
                OpenApiExample(
                    name="already accepted",
                    value={"msg": MSG_FAIL.format(15, "ACC")},
                ),
                OpenApiExample(
                    name="already expired",
                    value={"msg": MSG_FAIL.format(15, "EXP")},
                ),
                OpenApiExample(
                    name="already canceled",
                    value={"msg": MSG_FAIL.format(15, "CAN")},
                ),
                Schema_Response.SERIALIZER_VALIDATION_ERRORS.examples[0],
            ],
        ),
    }

    @extend_schema(
        description=f"Cancel a sent activity identified by activityid and the user auth token by setting its status to {FriendActivityStatus.CANCEL}.\n\n Only pending activities can be canceled.",
        request=TargetActivitySerializer,
        responses=RESPONSES,
    )
    def patch(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        activityid = serialized.validated_data["activityid"]

        try:
            activity = self.model.objects.get(
                activityid=activityid,
                fromUserid=request.user.userid,  # type: ignore
            )

            if (
                activity.status == FriendActivityStatus.PENDING
                and activity.cancel_activity()
            ):
                return Response(
                    {
                        "msg": MSG_PASS.format(
                            activityid,
                            FriendActivityStatus.CANCEL,
                        )
                    },
                    status=status.HTTP_200_OK,
                )

            return Response(
                {
                    "msg": MSG_FAIL.format(
                        activityid,
                        activity.status,
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        except ObjectDoesNotExist:
            return Response(
                {
                    "msg": MSG_FAIL.format(activityid, "NOT FOUND"),
                },
                status=status.HTTP_404_NOT_FOUND,
            )


@extend_schema(summary="Reject a pending received activity", tags=[Tags.ACTIVITY])
class RejectActivityView(AbstractActivityView):
    serializer_class = TargetActivitySerializer

    @extend_schema(
        description=f"Reject a received activity identified by activityid and the user auth token by setting its status to {FriendActivityStatus.REJECT}.\n\n Only pending activities can be rejected.",
        request=TargetActivitySerializer,
    )
    def patch(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        activityid = serialized.validated_data["activityid"]

        try:
            activity = self.model.objects.get(
                activityid=activityid,
                toUserid=request.user.userid,  # type: ignore
            )

            if (
                activity.status == FriendActivityStatus.PENDING
                and activity.reject_activity()
            ):
                return Response(
                    {"msg": MSG_PASS.format(activityid, FriendActivityStatus.REJECT)},
                    status=status.HTTP_200_OK,
                )
            return Response(
                {"msg": MSG_FAIL.format(activityid, activity.status)},
                status=status.HTTP_400_BAD_REQUEST,
            )

        except ObjectDoesNotExist:
            return Response(
                {"msg": MSG_FAIL.format(activityid, "NOT FOUND")},
                status=status.HTTP_404_NOT_FOUND,
            )
