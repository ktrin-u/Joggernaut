from rest_framework.generics import GenericAPIView, CreateAPIView
from rest_framework import permissions

from drf_spectacular.utils import extend_schema

from oauth2_provider.views import TokenView, RevokeTokenView

from api.schema_docs import Tags
from api.permissions import isBanned
from api.serializers.token import (
    TokenResponseSerializer,
    TokenSerializer,
    RevokeTokenSerializer,
)
from api.serializers.user import RegisterFormSerializer
from api.models import User


@extend_schema(
    summary="Register new user account",
    tags=[Tags.AUTH],
)
class CreateUserView(CreateAPIView):
    model = User
    permission_classes = [permissions.AllowAny]  # Or anon users can't register
    serializer_class = RegisterFormSerializer


@extend_schema(
    summary="Alternative to /api/auth/token/",
    tags=[Tags.AUTH],
)
class TokenAPIView(TokenView, GenericAPIView):
    serializer_class = TokenSerializer
    permission_classes = [isBanned]

    @extend_schema(
        description="For acquiring an access token", responses=TokenResponseSerializer
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


@extend_schema(
    summary="Alternative to /api/auth/revoke_token/",
    tags=[Tags.AUTH],
)
class RevokeTokenAPIView(RevokeTokenView, GenericAPIView):
    serializer_class = RevokeTokenSerializer
    permission_classes = [isBanned]

    @extend_schema(
        description="Implements an endpoint to revoke access tokens",
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
