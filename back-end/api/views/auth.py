from rest_framework import status
from rest_framework import permissions
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.generics import GenericAPIView, CreateAPIView

from drf_spectacular.utils import (
    extend_schema,
    OpenApiParameter,
    OpenApiResponse,
    OpenApiExample,
)

from oauth2_provider.views import TokenView, RevokeTokenView

from django.core.mail import send_mail
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.core.exceptions import ObjectDoesNotExist

from api.schema_docs import Tags
from api.permissions import isBanned
from api.serializers import (
    TokenResponseSerializer,
    TokenSerializer,
    RevokeTokenSerializer,
    ForgotPasswordEmailSerializer,
    ForgotPasswordTokenSerializer,
    MsgSerializer,
    UpdateUserPasswordSerializer,
)
from api.serializers import RegisterFormSerializer
from api.models import User, PasswordResetToken


MSG_FAIL = "FAIL:user {0} is {1}"

def verify_reset_token(user: User, token: str):
    try:
        return PasswordResetToken.objects.get(user_email=user, token=token).expired
    except Exception:
        return False

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




@extend_schema(
    summary="Use email-sent token to reset forgotten password",
    tags=[Tags.AUTH],
)
class ForgotPasswordOtpView(GenericAPIView):
    serializer_class = ForgotPasswordEmailSerializer
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        description="Send an email containing a token that is used to reset the password.",
    )
    def post(self, request: Request) -> Response:
        serialized = self.get_serializer(data=request.data)

        if not serialized.is_valid():
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serialized.errors)

        email: str = serialized.validated_data["email"]
        # Check if user is registered
        try:
            user = User.objects.get(email=email)
            token_generator = PasswordResetTokenGenerator()
            token = token_generator.make_token(user)
            entry = PasswordResetToken(user_email=user, token=token)
            entry.save()

            send_mail(
                subject="Reset Password Token",
                message=f"Your reset token is: {token}",
                from_email="noreply@trial-51ndgwv7w7dlzqx8.mlsender.net",
                recipient_list=[email],
                fail_silently=False,
            )

            return Response(
                status=status.HTTP_200_OK,
                data={"msg": f"PASS: Reset Token sent to {email}"},
            )

        except ObjectDoesNotExist:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={"msg": MSG_FAIL.format(email, "NOT FOUND")},
            )
        except Exception as e:
            return Response(
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                data={"msg": f"FAIL: error raised: {str(e)}"},
            )

    GET_PARAMS = [
        OpenApiParameter(
            name="email",
            type=str,
            location=OpenApiParameter.QUERY,
            required=True,
            description="The email of the user whose token is being validated",
        ),
        OpenApiParameter(
            name="token",
            type=str,
            location=OpenApiParameter.QUERY,
            required=True,
            description="The token of the user being validated",
        ),
    ]

    @extend_schema(
        description="Verify the reset password token for a given user identified by email",
        request=ForgotPasswordTokenSerializer,
        responses=MsgSerializer,
        parameters=GET_PARAMS,
    )
    def get(self, request: Request) -> Response:
        serialized = ForgotPasswordTokenSerializer(data=request.query_params)

        if not serialized.is_valid():
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={"msg": "FAIL: missing token in query params"},
            )

        email = serialized.validated_data["email"]
        token = serialized.validated_data["token"]
        try:
            user = User.objects.get(email=email)
            if verify_reset_token(user, token):
                return Response(
                    status=status.HTTP_400_BAD_REQUEST,
                    data={"msg": "FAIL: token is invalid"},
                )
            return Response(
                status=status.HTTP_200_OK, data={"msg": "PASS: token is valid"}
            )
        except ObjectDoesNotExist:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={"msg": MSG_FAIL.format(email, "NOT FOUND")},
            )


@extend_schema(
    summary="Use a valid token to reset forgotten password", tags=[Tags.AUTH]
)
class ResetForgotPasswordView(GenericAPIView):
    permission_classes = [permissions.AllowAny]

    PARAMETERS = [
        OpenApiParameter(
            name="email",
            type=str,
            location=OpenApiParameter.HEADER,
            required=True,
            description="email of the user",
        ),
        OpenApiParameter(
            name="token",
            type=str,
            location=OpenApiParameter.HEADER,
            required=True,
            description="valid reset password token of the user",
        ),
    ]

    @extend_schema(
        description="",
        parameters=PARAMETERS,
        request=UpdateUserPasswordSerializer,
        responses=MsgSerializer,
    )
    def patch(self, request: Request) -> Response:
        headers = ForgotPasswordTokenSerializer(data=request.headers)

        if not headers.is_valid():
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data=headers.errors,
            )

        email = headers.validated_data["email"]
        token = headers.validated_data["token"]
        try:
            user = User.objects.get(email=email)
            if verify_reset_token(user, token):
                return Response(
                    status=status.HTTP_401_UNAUTHORIZED,
                    data={"msg": f"FAIL: token {token} is invalid"},
                )

            serialized = UpdateUserPasswordSerializer(data=request.data)

            if not serialized.is_valid():
                return Response(
                    status=status.HTTP_400_BAD_REQUEST,
                    data=serialized.errors,
                )

            serialized.update(instance=user, validated_data=serialized.validated_data)
            return Response(
                status=status.HTTP_200_OK,
                data={"msg": f"PASS: user {email}'s password has been changed."},
            )

        except ObjectDoesNotExist:
            return Response(
                status=status.HTTP_404_NOT_FOUND,
                data={"msg": MSG_FAIL.format(email, "NOT FOUND")},
            )
