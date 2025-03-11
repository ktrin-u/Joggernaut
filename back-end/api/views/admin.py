from rest_framework.generics import GenericAPIView
from oauth2_provider.contrib.rest_framework import TokenHasScope
from drf_spectacular.utils import extend_schema
from django.contrib.auth import get_user_model
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework import permissions
from rest_framework import status
from api.schema_docs import Tags
from django.db.models import Q
from api.serializers.user import UpdateUserPermissionsSerializer


class AbstractUpdateUserUserPermissionsView(GenericAPIView):
    serializer_class = UpdateUserPermissionsSerializer
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
