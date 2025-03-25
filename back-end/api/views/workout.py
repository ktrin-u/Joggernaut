from copy import deepcopy

from django.core.exceptions import ObjectDoesNotExist
from drf_spectacular.utils import OpenApiExample, OpenApiResponse, extend_schema
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api import schema_docs
from api.helper import clean_request_data, get_user_object
from api.models.workout import WorkoutRecord
from api.responses import RESPONSE_USER_NOT_FOUND
from api.schema_docs import Tags
from api.serializers.general import MsgSerializer
from api.serializers.workout import (
    GetWorkoutRecordSerializer,
    NewWorkoutRecordRequestSerializer,
    NewWorkoutRecordSerializer,
    UpdateWorkoutRecordSerializer,
)


@extend_schema(
    summary="Create a new workout record",
    tags=[Tags.WORKOUT],
)
class CreateWorkoutRecordView(GenericAPIView):
    serializer_class = NewWorkoutRecordSerializer
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]

    RESPONSE_SUCCESS = Response(
        {"msg": "successfully created workout record"}, status=status.HTTP_200_OK
    )

    RESPONSE_BOTH_ZERO = Response(
        {"msg": "no entry made due to calories=0 and steps=0"},
        status=status.HTTP_406_NOT_ACCEPTABLE,
    )

    @extend_schema(
        description="Create a new workout record by supplying either calories, steps or both.",
        responses={
            RESPONSE_SUCCESS.status_code: OpenApiResponse(
                response=MsgSerializer,
                description="succesfully created workout record",
                examples=[
                    OpenApiExample(
                        name="success",
                        value=RESPONSE_SUCCESS.data,
                    ),
                ],
            ),
            RESPONSE_BOTH_ZERO.status_code: OpenApiResponse(
                response=MsgSerializer,
                description="calories=steps=0",
                examples=[
                    OpenApiExample(
                        name="accepted but no entry", value=RESPONSE_BOTH_ZERO.data
                    )
                ],
            ),
            RESPONSE_USER_NOT_FOUND.status_code: schema_docs.Response.AUTH_TOKEN_USER_NOT_FOUND,
        },
        request=NewWorkoutRecordRequestSerializer,
    )
    def post(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        data = deepcopy(request.data)
        data["userid"] = user.userid
        serializer = self.get_serializer(data=data)

        if serializer.is_valid():
            if (
                serializer.validated_data["calories"] == 0
                and serializer.validated_data["steps"] == 0
            ):
                return self.RESPONSE_BOTH_ZERO

            serializer.save()
            return self.RESPONSE_SUCCESS
        return Response(serializer.errors, status.HTTP_400_BAD_REQUEST)


@extend_schema(
    summary="Get list of workouts for the user",
    tags=[Tags.WORKOUT],
)
class GetWorkoutRecordView(GenericAPIView):
    serializer_class = GetWorkoutRecordSerializer
    permission_classes = [TokenHasScope]
    required_scopes = ["read"]
    model = WorkoutRecord

    def get(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        workouts = self.get_serializer(
            self.model.objects.filter(userid=user.userid), many=True
        )

        return Response(data=workouts.data, status=status.HTTP_200_OK)


@extend_schema(summary="Update a workout record", tags=[Tags.WORKOUT])
class UpdateWorkoutRecordView(GenericAPIView):
    serializer_class = UpdateWorkoutRecordSerializer
    permission_classes = [TokenHasScope]
    required_scopes = ["write"]
    model = WorkoutRecord

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
            value={
                "msg": "workout id 15 under eb28f55f-fd95-43ce-ba91-e279bcdc9e6f not found"
            },
        )
    )

    @extend_schema(
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
                        value={
                            "msg": "success, calories updated to 2340, steps updated to 8792, "
                        },
                    ),
                ],
            ),
            status.HTTP_400_BAD_REQUEST: _bad_request,
        },
    )
    def patch(self, request: Request) -> Response:
        user = get_user_object(request)
        if user is None:
            return RESPONSE_USER_NOT_FOUND

        data = clean_request_data(request)
        serialized = self.get_serializer(data=data)

        if serialized.is_valid():
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

                msg = "success, "
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
                        "msg": f"workout id {serialized.validated_data['workoutid']} under {user.userid} not found"
                    },
                    status=status.HTTP_404_NOT_FOUND,
                )

        return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)
