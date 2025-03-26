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
const acceptActivityURL = "${hostURL}api/activity/accept";
const cancelActivityURL = "${hostURL}api/activity/cancel";
const rejectActivityURL = "${hostURL}api/activity/reject";
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
const createUserProfileURL = "${hostURL}api/profile/new";
const updateUserProfileURL = "${hostURL}api/profile/update";

// workout
const getWorkoutURL = "${hostURL}api/workout";
const createWorkoutURL = "${hostURL}api/workout/add";
const updateWorkoutURL = "${hostURL}api/workout/update";
