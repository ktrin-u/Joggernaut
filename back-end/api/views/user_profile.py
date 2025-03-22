from oauth2_provider.contrib.rest_framework import TokenHasScope

from drf_spectacular.utils import extend_schema

from rest_framework import status
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.generics import GenericAPIView

from api.schema_docs import Tags
from api.models.user import UserProfiles
from api.helper import get_user_object
from api.helper import clean_request_data
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
        user = get_user_object(request)
        if user is None:
            return Response(
                {"msg": "unable to find user"}, status=status.HTTP_404_NOT_FOUND
            )

        try:
            profile = self.model.objects.get(userid=user.userid)
            serializer = self.get_serializer_class()(profile)
            return Response(data=serializer.data, status=status.HTTP_200_OK)
        except UserProfiles.DoesNotExist:
            return Response(
                {"msg": "User profile does not exist"}, status=status.HTTP_404_NOT_FOUND
            )


@extend_schema(
    summary="Create new user profile",
    tags=[Tags.PROFILE],
)
class CreateUserProfileView(AbstractUserProfileView):
    required_scopes = ["write"]

    @extend_schema(description="TBA")
    def post(self, request: Request, format=None) -> Response:
        serialized = UserProfileFormSerializer(data=request.data)
        if serialized.is_valid():
            serialized.save()
            return Response(
                {"msg": "user profile created"}, status=status.HTTP_201_CREATED
            )

        return Response(data=serialized.errors, status=status.HTTP_406_NOT_ACCEPTABLE)


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
        user = get_user_object(request)

        if user is None:
            return Response(
                {"msg": "unable to find user"}, status=status.HTTP_404_NOT_FOUND
            )

        try:
            profile = self.model.objects.get(userid=user.userid)
            serializer = self.get_serializer_class()
            serialized = serializer(
                instance=profile, data=clean_request_data(request), partial=True
            )

            if serialized.is_valid():
                serialized.save()
                return Response(data=serialized.data, status=status.HTTP_201_CREATED)

            return Response(
                data=serialized.errors, status=status.HTTP_406_NOT_ACCEPTABLE
            )

        except UserProfiles.DoesNotExist:
            return Response(
                {"msg": "User profile does not exist"}, status=status.HTTP_404_NOT_FOUND
            )
