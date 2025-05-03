from drf_spectacular.utils import OpenApiParameter, OpenApiResponse, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api.models import GameSave, User, UserProfiles, WorkoutRecord
from api.schema_docs import Tags
from api.serializers import (
    GetLeaderboardRequestSerializer,
    LeaderboardCategories,
)


@extend_schema(tags=[Tags.LEADERBOARDS])
class LeaderboardsView(GenericAPIView):
    serializer_class = GetLeaderboardRequestSerializer
    required_scopes = ["read"]

    @extend_schema(
        parameters=[
            OpenApiParameter(
                name="category",
                type=str,
                required=True,
                location=OpenApiParameter.QUERY,
                enum=[cat for cat in LeaderboardCategories],
            ),
            OpenApiParameter(
                name="top_n",
                type=int,
                required=True,
                location=OpenApiParameter.QUERY,
                default=5,
            ),
        ],
        responses={
            status.HTTP_200_OK: OpenApiResponse(
                response={
                    "leaderboard": {
                        "John T.": 5555,
                        "John D.": 1023,
                        "Fred K.": 550,
                    }
                }
            )
        },
        summary="Get the {top_n} leaderboard for {category}.",
    )
    def get(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        serialized = GetLeaderboardRequestSerializer(data=request.query_params)

        serialized.is_valid(raise_exception=True)

        category: LeaderboardCategories = serialized.validated_data["category"]
        top_n = serialized.validated_data["top_n"]

        leaderboards = []
        match category:
            case LeaderboardCategories.STEPS:
                users = User.objects.all()
                for user in users:
                    if not user.check_perm("in_leaderboards"):
                        continue

                    workouts = WorkoutRecord.objects.filter(userid=user)
                    sum = 0

                    for workout in workouts:
                        sum += workout.steps

                    profile = UserProfiles.objects.get(userid=user)
                    leaderboards.append((profile.accountname, sum))

            case LeaderboardCategories.ATTEMPTS:
                records = (
                    GameSave.objects.all().order_by("attempts_lifetime").select_related("owner")
                )

                for record in records:
                    if not record.owner.check_perm("in_leaderboards"):
                        continue

                    profile = UserProfiles.objects.get(userid=record.owner)
                    leaderboards.append((profile.accountname, record.attempts_lifetime))

        leaderboards.sort(key=lambda x: x[1], reverse=True)

        return Response(status=status.HTTP_200_OK, data={"leaderboard": leaderboards[:top_n]})
