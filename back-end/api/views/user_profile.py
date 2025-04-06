from django.core.exceptions import ObjectDoesNotExist
from drf_spectacular.utils import extend_schema
from oauth2_provider.contrib.rest_framework import TokenHasScope
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response

from api.models import User, UserProfiles
from api.schema_docs import Tags
from api.serializers.user_profile import UserProfileFormSerializer


class AbstractUserProfileView(GenericAPIView):
    serializer_class = UserProfileFormSerializer
    model = UserProfiles
    permission_classes = [TokenHasScope]
    required_scopes = []


@extend_schema(
    summary="View user profile",
    tags=[Tags.PROFILE],
)
class UserProfileView(AbstractUserProfileView):
    required_scopes = ["read"]

    @extend_schema(description="Uses the Authentication Token as identifier")
    def get(self, request: Request, format=None) -> Response:
        user = request.user
        assert isinstance(user, User)
        try:
            profile = self.model.objects.get(userid=user.userid)
            serializer = self.get_serializer(instance=profile)
            return Response(data=serializer.data, status=status.HTTP_200_OK)
        except ObjectDoesNotExist:
            return Response(
                {"msg": f"FAIL: User profile for user {user.userid} is NOT FOUND"},
                status=status.HTTP_404_NOT_FOUND,
            )


@extend_schema(
    summary="Update user profile",
    tags=[Tags.PROFILE],
)
class UpdateUserProfileView(AbstractUserProfileView):
    required_scopes = ["write"]

    @extend_schema(
        description="Updates the relevant entry in the database. Does not expect all fields. This uses the Authentication Token as the identifier."
    )
    def patch(self, request: Request) -> Response:
        user = request.user
        assert isinstance(user, User)
        try:
            serialized = self.get_serializer(data=request.data, partial=True)

            if not serialized.is_valid():
                return Response(data=serialized.errors, status=status.HTTP_400_BAD_REQUEST)

            profile = self.model.objects.get(userid=user.userid)
            serialized.update(profile, serialized.validated_data)
            return Response(data=serialized.data, status=status.HTTP_200_OK)

        except ObjectDoesNotExist:
            return Response(
                {"msg": f"FAIL: User profile for user {user.userid} is NOT FOUND"},
                status=status.HTTP_404_NOT_FOUND,
            )
