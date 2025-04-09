const hostURL = "http://10.0.2.2:8000/";

// admin
const banURL = "${hostURL}api/admin/ban/";
const unbanURL = "${hostURL}api/admin/unban/";

// friends
const getFriendsURL = "${hostURL}api/friends/";
const addFriendURL = "${hostURL}api/friends/add";
const cancelRequestURL = "${hostURL}api/friends/cancel";
const acceptRequestURL = "${hostURL}api/friends/accept";
const rejectRequestURL = "${hostURL}api/friends/reject";
const unFriendURL = "${hostURL}api/friends/remove";
const getPendingFriendsURL = "${hostURL}api/friends/pending";

// activity
const getActivitiesURL = "${hostURL}api/activity";
const updateActivityURL = "${hostURL}api/activity/update";
const challengeFriendURL = "${hostURL}api/activity/challenge";
const pokeFriendURL = "${hostURL}api/activity/poke";

// auth
const forgetPasswordURL = "${hostURL}api/forgot/password/";
const forgetPasswordChangeURL = "${hostURL}api/forgot/password/change";
const registerURL = "${hostURL}api/register/";
const loginURL = "${hostURL}api/login/";
const logoutURL = "${hostURL}api/logout/";

// user
const deleteAccURL = "${hostURL}api/user/delete";
const changePasswordURL = "${hostURL}api/user/password/change";
const getAllUsersURL = "${hostURL}api/user";
const getUserInfoURL = "${hostURL}api/user/info/";
const updateUserInfoURL = "${hostURL}api/user/info/update";

// profile
const getUserProfileURL = "${hostURL}api/profile";
const updateUserProfileURL = "${hostURL}api/profile/update";

// workout
const workoutURL = "${hostURL}api/workout/";

//game
const gameSaveURL = "${hostURL}api/game";
const characterURL = "${hostURL}api/game/character/";
const gameStatsURL = "${hostURL}api/game/stats/";

//leaderboard
const leaderboardURL = "${hostURL}api/leaderboards";