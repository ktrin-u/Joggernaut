from django.contrib.auth.models import AbstractBaseUser, AnonymousUser
from django.core.exceptions import ObjectDoesNotExist
from drf_spectacular.utils import (
    OpenApiParameter,
    extend_schema,
)
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api.models import GameCharacter, GameSave, User
from api.schema_docs import RESPONSEMSG, Tags
from api.serializers import (
    CreateGameCharacterSerializer,
    CreateGameSaveSerializer,
    EditCharacterSerializer,
    GameCharacterSerializer,
    TargetCharacterSerializer,
)


@extend_schema(tags=[Tags.GAME])
class AbstractGameView(GenericAPIView):
    permission_classes = [TokenHasScope]
    ...

    def get_gamesave_object(self, user: AbstractBaseUser | AnonymousUser | User) -> GameSave:
        try:
            if not isinstance(user, User):
                raise TypeError(f"User object is type {type(user)}")
            return GameSave.objects.get(owner=user)
        except Exception as e:
            raise e


@extend_schema(
    summary="Get or create a GameSave entry for a user",
)
class GameSaveView(AbstractGameView):
    required_scopes = ["write"]
    serializer_class = CreateGameSaveSerializer

    @extend_schema(
        description="Get or create a game save for the user by the auth header.",
        request=None,
        responses=RESPONSEMSG,
    )
    def get(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)

        game_save, new = GameSave.objects.get_or_create(owner=user)

        if new:
            return Response(
                status=status.HTTP_201_CREATED,
                data={
                    "msg": f"PASS:gamesave {game_save.id} has been created for user {user.email}."
                },
            )

        return Response(
            status=status.HTTP_200_OK,
            data={"msg": f"PASS: user {user.email} has gamesave {game_save.id}"},
        )


class GameCharacterView(AbstractGameView):
    model = GameCharacter
    required_scopes = ["read", "write"]
    serializer_class = GameCharacterSerializer

    @extend_schema(
        summary="Get list of existing game characters",
        request=None,
        responses=GameCharacterSerializer(many=True),
    )
    def get(self, request: Request) -> Response:
        self.serializer_class = GameCharacterSerializer
        user = request.user
        assert isinstance(user, User)

        try:
            game_save = GameSave.objects.get(owner=user)

            characters_queryset = GameCharacter.objects.filter(gamesave_id=game_save.id)

            serialized = self.get_serializer(instance=characters_queryset, many=True)

            return Response(status=status.HTTP_200_OK, data={"characters": serialized.data})

        except ObjectDoesNotExist as e:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={
                    "msg": f"FAIL: {e}",
                },
            )

    @extend_schema(
        summary="Create a new game character",
        request=CreateGameCharacterSerializer,
        responses=RESPONSEMSG,
    )
    def post(self, request: Request) -> Response:
        self.serializer_class = CreateGameCharacterSerializer
        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serialized.errors)

        game_save = self.get_gamesave_object(request.user)

        if game_save is Exception:
            return Response(status=status.HTTP_404_NOT_FOUND, data={"msg": f"FAIL:{game_save}"})

        new_character = self.model.objects.create(
            gamesave_id=game_save, **serialized.validated_data
        )

        return Response(
            status=status.HTTP_201_CREATED,
            data={
                "msg": f"PASS: character {new_character.name} for user {request.user} has been created",
            },
        )

    DELETE_QUERY_PARMS = [
        OpenApiParameter(
            name="id",
            type=int,
            location=OpenApiParameter.QUERY,
            required=True,
            description="ID of character to delete",
        )
    ]

    @extend_schema(
        summary="Delete a game character",
        request=None,
        parameters=DELETE_QUERY_PARMS,
        responses=RESPONSEMSG,
    )
    def delete(self, request: Request) -> Response:
        self.serializer_class = TargetCharacterSerializer
        serialized = self.get_serializer(data=request.query_params)

        if not serialized.is_valid():
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data=serialized.errors,
            )

        try:
            game_save = self.get_gamesave_object(request.user)
            character = self.model.objects.get(
                gamesave_id=game_save,
                id=serialized.validated_data["id"],
            )
            character.delete()
            return Response(
                status=status.HTTP_200_OK,
                data={"msg": f"PASS: character {character.name} has been deleted."},
            )

        except ObjectDoesNotExist:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={"msg": f"FAIL: Character {serialized.validated_data['id']} is NOT FOUND"},
            )
        except Exception as e:
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={"msg": f"FAIL: {e}"},
            )

    @extend_schema(
        summary="Update game character data", request=EditCharacterSerializer, responses=RESPONSEMSG
    )
    def patch(self, request: Request) -> Response:
        self.serializer_class = EditCharacterSerializer
        serialized = self.get_serializer(data=request.data, partial=True)
        if not serialized.is_valid():
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data=serialized.errors,
            )
        id = serialized.validated_data.get("id")

        if id is None:
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={"msg": f"FAIL: provided id {id} is NOT VALID"},
            )

        try:
            if (
                len(serialized.validated_data) == 2
                and serialized.validated_data["selected"] is None
            ):
                return Response(
                    status=status.HTTP_200_OK, data={"msg": "PASS: no changes have been made"}
                )

            instance = self.model.objects.get(id=id)
            serialized.update(instance, serialized.validated_data)

            return Response(
                status=status.HTTP_202_ACCEPTED,
                data={"msg": f"PASS: successfully updated character {instance.id}"},
            )

        except ObjectDoesNotExist:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={"msg": f"FAIL: Gamecharacter {id} for user {request.user.email}is NOT FOUND"},  # type: ignore
            )
