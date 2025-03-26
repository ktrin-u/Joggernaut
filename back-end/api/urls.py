from django.urls import path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from api.views import activity, admin, auth, friends, game, user, user_profile, workout

schema_urls = [
    path("", SpectacularSwaggerView.as_view(url_name="schema"), name="overview"),
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
]

admin_urls = [
    path("admin/ban/", admin.BanUserView.as_view(), name="ban a user"),
    path("admin/unban/", admin.UnbanUserView.as_view(), name="unban a user"),
]


auth_urls = [
    path("register/", auth.CreateUserView.as_view(), name="register new user"),
    path("login/", auth.TokenAPIView.as_view(), name="login and acquire token"),
    path("logout/", auth.RevokeTokenAPIView.as_view(), name="logout and revoke token"),
    path(
        "forgot/password/",
        auth.ForgotPasswordOtpView.as_view(),
        name="send otp for password reset",
    ),
    path(
        "forgot/password/change",
        auth.ResetForgotPasswordView.as_view(),
        name="change forgot password",
    ),
]

profile_urls = [
    path("profile/", user_profile.UserProfileView.as_view(), name="retrieve user profile"),
    path(
        "profile/new",
        user_profile.CreateUserProfileView.as_view(),
        name="create new user profile",
    ),
    path(
        "profile/update",
        user_profile.UpdateUserProfileView.as_view(),
        name="update user profile",
    ),
]

user_urls = [
    path("user/", user.GetUsersView.as_view(), name="get list of users"),
    path("user/info/", user.ViewUserInfoView.as_view(), name="retrieve user info"),
    path("user/delete", user.DeleteUserView.as_view(), name="delete user account"),
    path("user/info/update", user.UpdateUserInfoView.as_view(), name="update user info"),
    path(
        "user/password/change",
        user.UpdateUserPasswordView.as_view(),
        name="change user password",
    ),
]

friend_urls = [
    path("friends/", friends.GetFriendsView.as_view(), name="get friend list"),
    path(
        "friends/add",
        friends.SendFriendRequestView.as_view(),
        name="send friend request",
    ),
    path(
        "friends/cancel",
        friends.CancelPendingFriendView.as_view(),
        name="cancel sent pending friend request",
    ),
    path(
        "friends/accept",
        friends.AcceptFriendView.as_view(),
        name="accept friend request",
    ),
    path(
        "friends/reject",
        friends.RejectFriendView.as_view(),
        name="reject friend request",
    ),
    path("friends/remove", friends.RemoveFriendView.as_view(), name="unfriend a friend"),
    path(
        "friends/pending",
        friends.GetPendingFriendsView.as_view(),
        name="get pending friend list",
    ),
]

activity_urls = [
    path(
        "activity",
        activity.GetFriendActivityView.as_view(),
        name="get activities between user and friends",
    ),
    path("activity/poke", activity.PokeFriendView.as_view(), name="poke a friend"),
    path(
        "activity/accept",
        activity.AcceptActivityFriendView.as_view(),
        name="accept a pending friend activity",
    ),
    path(
        "activity/reject",
        activity.RejectActivityView.as_view(),
        name="reject a pending friend activity",
    ),
    path(
        "activity/challenge",
        activity.ChallengeFriendView.as_view(),
        name="challenge a friend",
    ),
    path(
        "activity/cancel",
        activity.CancelActivityView.as_view(),
        name="cancel a pending activity",
    ),
]

workout_urls = [
    path("workout/", workout.GetWorkoutRecordView.as_view(), name="get workout records"),
    path(
        "workout/add",
        workout.CreateWorkoutRecordView.as_view(),
        name="create new workout record",
    ),
    path(
        "workout/update",
        workout.UpdateWorkoutRecordView.as_view(),
        name="update workout records",
    ),
]

game_urls = [
    path("game/", game.GameSaveView.as_view(), name="access game save"),
    path("game/character/", game.GameCharacterView.as_view(), name="get characters"),
]


urlpatterns = [
    *schema_urls,
    *admin_urls,
    *auth_urls,
    *profile_urls,
    *user_urls,
    *friend_urls,
    *activity_urls,
    *workout_urls,
    *game_urls,
]
