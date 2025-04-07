from copy import deepcopy
from uuid import UUID

from django.core.exceptions import ObjectDoesNotExist
from drf_spectacular.utils import OpenApiExample, OpenApiParameter, OpenApiResponse, extend_schema
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api import schema_docs
from api.models import User, WorkoutRecord
from api.permissions import CanShareWorkout
from api.schema_docs import Tags
from api.serializers import (
    MsgSerializer,
    NewWorkoutRecordSerializer,
    UpdateWorkoutRecordSerializer,
    UserIdFilterSerializer,
    WorkoutRecordSerializer,
)


@extend_schema(
    summary="Create a new workout record",
    tags=[Tags.WORKOUT],
)
class WorkoutRecordView(GenericAPIView):
    model = WorkoutRecord
    serializer_class = WorkoutRecordSerializer
    permission_classes = [TokenHasScope, CanShareWorkout]
    required_scopes = ["write", "read"]

    RESPONSE_SUCCESS = Response(
        {"msg": "successfully created workout record"}, status=status.HTTP_200_OK
    )

    RESPONSE_BOTH_ZERO = Response(
        {"msg": "no entry made due to calories=0 and steps=0"},
        status=status.HTTP_406_NOT_ACCEPTABLE,
    )

    @extend_schema(
        summary="Get list of workouts for the user",
        description="Retrieves all the workout id with the userid of the user identified by the auth token.",
        parameters=[
            OpenApiParameter(
                name="userid",
                type=UUID,
                location=OpenApiParameter.QUERY,
                required=False,
                description="Filter by specified userid",
            )
        ],
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                NewWorkoutRecordSerializer,
                examples=[
                    OpenApiExample(
                        name="no filter",
                        value={
                            "workouts": [
                                {
                                    "workoutid": 69,
                                    "activityid": "null",
                                    "calories": 100,
                                    "steps": 100,
                                    "lastUpdate": "2025-03-13T09:31:57.704166+08:00",
                                    "userid": "acd9c5e5-aef5-435a-8bdb-ea0432f24ac7",
                                    "creationDate": "2025-03-13T09:31:57.704136+08:02",
                                },
                                {
                                    "workoutid": 25,
                                    "activityid": "null",
                                    "calories": 100,
                                    "steps": 100,
                                    "lastUpdate": "2025-03-13T20:20:32.134271+08:00",
                                    "userid": "c2092dae-f1b12-4cb7-8fdd-c863c542a695",
                                    "creationDate": "2025-03-13T16:17:32.134241+08:00",
                                },
                            ]
                        },
                        status_codes=[status.HTTP_200_OK],
                    ),
                    OpenApiExample(
                        name="has filter",
                        value={
                            "workouts": [
                                {
                                    "workoutid": 40,
                                    "activityid": "13",
                                    "calories": 100,
                                    "steps": 100,
                                    "lastUpdate": "2025-03-13T09:31:57.704166+08:00",
                                    "userid": "acd9c5e5-aef5-435a-8bdb-ea0432f24ac7",
                                    "creationDate": "2025-03-13T09:31:57.704136+08:02",
                                },
                                {
                                    "workoutid": 25,
                                    "activityid": "null",
                                    "calories": 107,
                                    "steps": 100,
                                    "lastUpdate": "2025-03-13T20:20:32.134271+08:00",
                                    "userid": "acd9c5e5-aef5-435a-8bdb-ea0432f24ac7",
                                    "creationDate": "2025-03-13T16:17:32.134241+08:00",
                                },
                            ]
                        },
                        status_codes=[status.HTTP_200_OK],
                    ),
                    OpenApiExample(
                        name="empty", value={"workouts": []}, status_codes=[status.HTTP_200_OK]
                    ),
                ],
            )
        },
    )
    def get(self, request: Request) -> Response:
        self.serializer_class = WorkoutRecordSerializer

        serialized = UserIdFilterSerializer(data=request.query_params, partial=True)

        if not serialized.is_valid():
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data=serialized.errors,
            )
        print(serialized.validate_empty_values)
        print(serialized.validated_data)
        userid_filter = serialized.validated_data.get("userid")

        if userid_filter is None:
            workouts = self.get_serializer(instance=self.model.objects.all(), many=True)
        else:
            workouts = self.get_serializer(
                self.model.objects.filter(userid=userid_filter), many=True
            )

        return Response(data={"workouts": workouts.data}, status=status.HTTP_200_OK)

    @extend_schema(
        description="Create a new workout record by supplying either calories, steps or both. Userid is automatically populated with the userid of the authenticated user",
        responses=schema_docs.RESPONSEMSG,
        request=NewWorkoutRecordSerializer,
    )
    def post(self, request: Request) -> Response:
        self.serializer_class = NewWorkoutRecordSerializer
        user = request.user
        assert isinstance(user, User)

        data = deepcopy(request.data)
        if data.get("userid") in [None, ""]:
            data["userid"] = user.userid

        serialized = self.get_serializer(data=data)

        if not serialized.is_valid():
            return Response(serialized.errors, status.HTTP_400_BAD_REQUEST)

        new = serialized.create(serialized.validated_data)
        return Response(
            status=status.HTTP_201_CREATED,
            data={
                "msg": f"PASS: succesfully created workout record {new.workoutid} for {new.userid}"
            },
        )

    _bad_request = deepcopy(schema_docs.Response.SERIALIZER_VALIDATION_ERRORS)
    _bad_request.examples.append(  # type: ignore
        OpenApiExample(
            name="no new values",
            value={"msg": "no new values supplied"},
        )
    )

    _not_found = deepcopy(schema_docs.Response.AUTH_TOKEN_USER_NOT_FOUND)
    _not_found.examples.append(  # type: ignore
        OpenApiExample(
            name="invalid workoutid",
            value={"msg": "workout id 15 under eb28f55f-fd95-43ce-ba91-e279bcdc9e6f not found"},
        )
    )

    @extend_schema(
        summary="Update a workout record",
        description="Update a workout entry with the supplied data. Empty values will be left untouched.",
        request=UpdateWorkoutRecordSerializer,
        responses={
            status.HTTP_404_NOT_FOUND: _not_found,
            status.HTTP_201_CREATED: OpenApiResponse(
                response=MsgSerializer,
                examples=[
                    OpenApiExample(
                        name="new calories",
                        value={
                            "msg": "success, calories updated to 1230, ",
                        },
                    ),
                    OpenApiExample(
                        name="new steps",
                        value={"msg": "success, steps updated to 4540, "},
                    ),
                    OpenApiExample(
                        name="new calories and steps",
                        value={"msg": "success, calories updated to 2340, steps updated to 8792, "},
                    ),
                ],
            ),
            status.HTTP_400_BAD_REQUEST: _bad_request,
        },
    )
    def patch(self, request: Request) -> Response:
        self.serializer_class = UpdateWorkoutRecordSerializer
        user = request.user
        assert isinstance(user, User)

        serialized = self.get_serializer(data=request.data, partial=True)

        if not serialized.is_valid():
            return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

        try:
            workout = self.model.objects.get(
                userid=user.userid, workoutid=serialized.validated_data["workoutid"]
            )
            new_calories = serialized.validated_data.get("calories")
            new_steps = serialized.validated_data.get("steps")

            if new_steps is None and new_steps is None:
                return Response(
                    {"msg": "no new values supplied"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            msg = "PASS: "
            if new_calories is not None:
                workout.calories = new_calories
                msg += f"calories updated to {new_calories}, "
            if new_steps is not None:
                workout.steps = new_steps
                msg += f"steps updated to {new_steps}, "

            workout.save()

            return Response(
                {
                    "msg": msg,
                },
                status=status.HTTP_201_CREATED,
            )

        except ObjectDoesNotExist:
            return Response(
                {
                    "msg": f"FAIL: workout id {serialized.validated_data['workoutid']} under {user.userid} is NOT FOUND"
                },
                status=status.HTTP_404_NOT_FOUND,
            )
