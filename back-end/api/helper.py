from oauth2_provider.models import AccessToken
from rest_framework.request import Request
from rest_framework import status
from rest_framework.response import Response
from .models import User


def get_token_from_header(request: Request) -> tuple[str, str]:
    """
    This function gets the token type and token from the Authorization header.
    It returns in the form (token_type, token)
    """
    authorization_header = request.headers.get("Authorization")

    if authorization_header is not None:
        split_header = authorization_header.split(" ")
        if len(split_header) != 2:
            return ("", "")
        return tuple(split_header)  # type: ignore

    return ("", "")


def get_user_from_token(token: str) -> User | None:
    """
    This function gets the corresponding User object associated with the provided token
    """
    try:
        access_token: AccessToken = AccessToken.objects.get(token=token)

        user: User = User.objects.get(email=access_token.user)

        return user

    except AccessToken.DoesNotExist:
        return None
    except User.DoesNotExist:
        return None


def get_user_object(request: Request) -> User | None:
    """
    Wrapper function which combines get_user_from_token and get_token_from_header
    """
    _, token = get_token_from_header(request)
    return get_user_from_token(token)


def get_user_object_or_404(request: Request) -> User | Response:
    _, token = get_token_from_header(request)
    ret = get_user_from_token(token)
    if ret is None:
        return Response(
            {
                "msg": "unable to find user"
            },
            status=status.HTTP_404_NOT_FOUND
        )
    return ret
