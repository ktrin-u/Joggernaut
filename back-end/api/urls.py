from django.urls import path

from drf_spectacular.views import SpectacularSwaggerView, SpectacularAPIView

from api.views import admin, auth, friends, user_profile, user, workout

urlpatterns = [
    path('', SpectacularSwaggerView.as_view(url_name='schema'), name='overview'),
    path('schema/', SpectacularAPIView.as_view(), name='schema'),

    path("admin/ban/", admin.BanUserView.as_view(), name="ban a user"),
    path("admin/unban/", admin.UnbanUserView.as_view(), name="unban a user"),

    path("register/", auth.CreateUserView.as_view(), name="register new user"),
    path('login/', auth.TokenAPIView.as_view(), name="login and acquire token"),
    path('logout/', auth.RevokeTokenAPIView.as_view(), name="logout and revoke token"),

    path("user/profile/", user_profile.UserProfileView.as_view(), name="retrieve user profile"),
    path("user/profile/new", user_profile.CreateUserProfileView.as_view(), name="create new user profile"),
    path("user/profile/update", user_profile.UpdateUserProfileView.as_view(), name="update user profile"),

    path("user/", user.GetUsersView.as_view(), name="get list of users"),
    path("user/info/", user.ViewUserInfoView.as_view(), name="retrieve user info"),
    path("user/delete", user.DeleteUserView.as_view(), name="delete user account"),
    path("user/info/update", user.UpdateUserInfoView.as_view(), name="update user info"),
    path("user/password/change", user.UpdateUserPasswordView.as_view(), name="change user password"),

    path('user/friends/', friends.GetFriendsView.as_view(), name="get friend list"),
    path('user/friends/add', friends.SendFriendRequestView.as_view(), name="send friend request"),
    path('user/friends/cancel', friends.CancelPendingFriendView.as_view(), name="cancel sent pending friend request"),
    path('user/friends/accept', friends.AcceptFriendView.as_view(), name="accept friend request"),
    path('user/friends/reject', friends.RejectFriendView.as_view(), name="reject friend request"),
    path('user/friends/remove', friends.RemoveFriendView.as_view(), name="unfriend a friend"),
    path('user/friends/pending', friends.GetPendingFriendsView.as_view(), name="get pending friend list"),

    path('user/friends/poke', friends.PokeFriendView.as_view(), name="poke a friend"),
    path('user/friends/challenge', friends.ChallengeFriendView.as_view(), name="challenge a friend"),
    path('user/friends/activity', friends.GetFriendActivityView.as_view(), name="get activities between user and friends"),

    path('user/workout/', workout.GetWorkoutRecordView.as_view(), name="get workout records"),
    path('user/workout/add', workout.CreateWorkoutRecordView.as_view(), name="create new workout record"),
    path('user/workout/update', workout.UpdateWorkoutRecordView.as_view(), name="update workout records"),
]
