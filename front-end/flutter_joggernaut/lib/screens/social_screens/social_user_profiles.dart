// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';
import 'package:intl/intl.dart';

class SocialUserProfilePage extends StatefulWidget {
  final String userId;
  final String userName;

  const SocialUserProfilePage({
    super.key, 
    required this.userId,
    required this.userName
  });

  @override
  State<SocialUserProfilePage> createState() => _SocialUserProfilePageState();
}

class _SocialUserProfilePageState extends State<SocialUserProfilePage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  final List<int> stepsPerDay = [1, 2, 3, 4, 5, 6, 7]; 
  late Future gettingUserProfile;
  late String userId; 
  late String userName;
  DateTime? deadline;
  String? myUserID;
  List friendIDs = [];
  String? durationChallenge;
  List<Map<String, dynamic>> pendingRequest = [];
  List<Map<String, dynamic>> friendActivities = [];
  Map<String, dynamic> latestChallenge = {};
  List<(DateTime, int)> sessions = [];
  bool isPoking = false;
  bool isLoadingCha = false;
  bool isLoadingAccFr = false;
  bool isLoadingRejFr = false;
  bool isLoadingFr = false;
  bool isFriends = false;
  bool isPending = false;
  bool hasReceived = false;
  bool pendingChallenge = false;
  bool ongoingChallenge = false;
 

  Future pokeFriend() async {
    setState(() {
      isPoking = true;
    });
    var response = await ApiService().pokeFriend(userId);
    if (response.statusCode == 201){
      ConfirmHelper.showResultDialog(_currentContext, "Poked $userName successfully!", "Success");
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isPoking = false;
    });
  }

  Future addFriend() async {
    setState(() {
      isLoadingFr = true;
    });
    var response = await ApiService().addFriend(userId);
    if (response.statusCode == 201){
      setState(() {
        isPending = true;
        isFriends = false;
        hasReceived = false;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoadingFr = false;
    });
  }

  Future unFriend() async {
    setState(() {
      isLoadingFr = true;
    });

    var response = await ApiService().unFriend(userId);
    if (response.statusCode == 200){
      setState(() {
        isFriends = false;
        isPending = false;
        hasReceived = false;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoadingFr = false;
    });
  }

  Future cancelRequest() async {
    setState(() {
      isLoadingFr = true;
    });
    var response = await ApiService().cancelRequest(userId);
    if (response.statusCode == 200){
      setState(() {
        isPending = false;
        isFriends = false;
        hasReceived = false;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoadingFr = false;
    });
  }

  Future acceptRequest() async {
    setState(() {
      isLoadingAccFr = true;
    });
    var response = await ApiService().acceptRequest(userId);
    if (response.statusCode == 200){
      setState(() {
        isPending = false;
        hasReceived = false; 
        isFriends = true;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoadingAccFr = false;
    });
  }

  Future rejectRequest() async {
    setState(() {
      isLoadingRejFr = true;
    });
    var response = await ApiService().rejectRequest(userId);
    if (response.statusCode == 200){
      setState(() {
        isPending = false;
        hasReceived = false; 
        isFriends = false;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoadingRejFr = false;
    });
  }
  
  Future getUserId() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    setState(() {
      myUserID = data["userid"];
    });
  }

  Future getFriends() async {
    var response = await ApiService().getFriends();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      List friends = List<Map<String, dynamic>>.from(data["friends"]); 
      friendIDs = friends.map((friend) {
          return friend["fromUserid"] == myUserID ? friend["toUserid"] : friend["fromUserid"];
        }).where((id) => id != myUserID).toList();
      setState(() {
        isFriends = friendIDs.contains(userId);
      });
    }
  }

  Future getPendingFriends() async {
    var response = await ApiService().getPendingFriends();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      List sentRequests = List<Map<String, dynamic>>.from(data["sent"]); 
      List receivedRequests = List<Map<String, dynamic>>.from(data["received"]); 
      setState(() {
        isPending = sentRequests.any((request) => request["toUserid"] == userId); 
        hasReceived = receivedRequests.any((request) => request["fromUserid"] == userId); 
      });
    }
  }

  Future addChallenge() async {
    setState(() {
      isLoadingCha = true;
    });
    var response = await ApiService().addChallenge(userId, durationChallenge);
    if (response.statusCode == 201){
      ConfirmHelper.showResultDialog(_currentContext, "Challenged $userName successfully.", "Success");
      await getFriendActivity();
      getLatestChallenge();
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
  }
  
  Future cancelChallenge() async {
    setState(() {
      isLoadingCha = true;
    });
    var response = await ApiService().cancelChallenge(latestChallenge["activityid"]);
    if (response.statusCode == 200){
      ConfirmHelper.showResultDialog(_currentContext, "Challenge cancelled successfully", "Success");
      await getFriendActivity();
      getLatestChallenge();
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
  }

  Future acceptChallenge() async {
    setState(() {
      isLoadingCha = true;
    });
    var response = await ApiService().acceptChallenge(latestChallenge["activityid"]);
    if (response.statusCode == 200){
      await getFriendActivity();
      getLatestChallenge();
      ConfirmHelper.showResultDialog(_currentContext, "Challenge accepted successfully", "Success");
    } 
    else if (response.statusCode == 400){
      ConfirmHelper.showResultDialog(_currentContext, "Challenge is expired", "Failed");
      await setup();
    }
  }

  Future rejectChallenge() async {
    setState(() {
      isLoadingCha = true;
    });
    var response = await ApiService().rejectChallenge(latestChallenge["activityid"]);
    if (response.statusCode == 200){
      await getFriendActivity();
      getLatestChallenge();
      ConfirmHelper.showResultDialog(_currentContext, "Challenge rejected successfully", "Success");
    } 
    else if (response.statusCode == 400){
      ConfirmHelper.showResultDialog(_currentContext, "Challenge is expired", "Failed");
      await setup();
    }
  }
  
  Future getFriendActivity() async {
    var response = await ApiService().getFriendActivity();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body)["activities"];
      setState(() {
        friendActivities = List<Map<String, dynamic>>.from(data); 
      });
    }
  }

  Future getWorkout() async {
    var response = await ApiService().getWorkout(userId);
    if (response.statusCode == 200){
      var jsonData = jsonDecode(response.body)["workouts"];
      jsonData = jsonData.length > 7 ? jsonData.sublist(jsonData.length - 7) : jsonData;
      jsonData.sort((a, b) => DateTime.parse(a["creationDate"]).compareTo(DateTime.parse(b["creationDate"])));
      setState(() {
        sessions = jsonData.map<(DateTime, int)>((w) => (
          DateTime.parse(w["lastUpdate"]).toUtc().add(Duration(hours: 8)),
          (w["steps"] as num).toInt(),
        )).toList();
      });
    }
  }

  void getLatestChallenge() {
    friendActivities = friendActivities.where((activity) {
      return activity["activity"] == "CHA" && (activity["fromUserid"] == userId || activity["toUserid"] == userId);
    }).toList();
  
    if (friendActivities.isNotEmpty){
      setState(() {
        latestChallenge = friendActivities.last;  
        deadline = DateTime.parse(latestChallenge["deadline"]).toUtc().add(Duration(hours: 8));
      });
    }

    if (latestChallenge != {}){
      if (latestChallenge['status'] == "EXP" && latestChallenge["fromUserid"] == userId){
        ConfirmHelper.showResultDialog(_currentContext, "Latest Challenge from $userName has expired", "Notification");
      }
      if (latestChallenge['status'] == "EXP" && latestChallenge["fromUserid"] == myUserID){
        ConfirmHelper.showResultDialog(_currentContext, "Your latest Challenge to $userName has expired", "Notification");
      }
      if (latestChallenge['status'] == "FIN" && latestChallenge["fromUserid"] == userId){
        ConfirmHelper.showResultDialog(_currentContext, "Latest Challenge from $userName has finished", "Notification");
      }
      if (latestChallenge['status'] == "FIN" && latestChallenge["fromUserid"] == myUserID){
        ConfirmHelper.showResultDialog(_currentContext, "Your latest Challenge to $userName has finished", "Notification");
      }
      if (latestChallenge['status'] == "ONG"){
        setState(() {
          ongoingChallenge = true;
        });
      }
      else if (latestChallenge['status'] == "PEN"){
        setState(() {
          pendingChallenge = true;
        });
      }
      else {
        setState(() {
          ongoingChallenge = false;
          pendingChallenge = false;
        });
      }
    }
    setState(() {
      isLoadingCha = false;
    });
  }

  Future selectDeadline() async {
    DateTime? selectedDate = await showDatePicker(
      context: context, 
      firstDate: DateTime.now().toUtc().add(Duration(hours: 8)).add(Duration(days: 1)), 
      lastDate: DateTime(2100).toUtc().add(Duration(hours: 8)),
      helpText: "Deadline of Challenge",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black87, 
            hintColor: Colors.black87, 
            colorScheme: ColorScheme.light(primary: Colors.black87),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    selectedDate = DateTime(
      selectedDate!.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
    );
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 8));
    Duration difference = selectedDate.difference(now);
    setState(() {
      deadline = selectedDate;
      durationChallenge = difference.inSeconds.toString();
    });
    ConfirmHelper.showConfirmDialog(_currentContext, "Are you sure you want to challenge $userName?\n\nStart of challenge: ${DateFormat("MMMM d, y").format(now)} at 12:00 AM\n\nDeadline of challenge: ${DateFormat("MMMM d, y 'at' hh:mm a").format(deadline!)}", (context) => addChallenge());
  }

  Future setup() async {
    await getUserId();
    await getFriends();
    await getPendingFriends();
    await getFriendActivity();
    await getWorkout();
    getLatestChallenge();
  }
  
  @override
  void initState(){
    super.initState();
    userId = widget.userId; 
    userName = widget.userName; 
    gettingUserProfile = setup();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(
        future: gettingUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
              color: Color.fromRGBO(51, 51, 51, 1),
              ) 
            ); 
          } else if (snapshot.hasError) {
              return Center(child: Text("Error loading friend's profile"));
          } else {
              return Column(
                children: [ 
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight*0.07, left: screenWidth*0.08, right: screenWidth*0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: (){
                            router.pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color.fromRGBO(51, 51, 51, 1),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                            iconSize: screenWidth * 0.045
                          ),
                          label: Text(
                            "Back",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              fontSize: screenWidth * 0.045
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight*0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontFamily: 'Big Shoulders Display',
                            fontSize: screenWidth * 0.13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                  
                      isFriends ? ElevatedButton(
                        onPressed: () {
                          ConfirmHelper.showConfirmDialog(context, "Are you sure you want to poke $userName?", (context) => pokeFriend());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.01,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isPoking ? 0.0 : 1.0, 
                              child: Text(
                                "Poke",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontSize: screenWidth * 0.035, 
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isPoking)
                            SizedBox(
                              height: screenWidth * 0.045, 
                              width: screenWidth * 0.045, 
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(51, 51, 51, 1),
                                strokeWidth: 2.5,
                              ),
                            ),
                          ]  
                        ),
                      ) :
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Poke",
                            style: TextStyle(
                              color: Color.fromARGB(255, 121, 119, 119),
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth*0.03),
                      isFriends ? ElevatedButton(
                        onPressed: () {
                          if (ongoingChallenge){
                            ConfirmHelper.showPlainActionDialog(
                              context, 
                              "Ongoing Challenge", 
                              "You have an ongoing challenge with $userName.\n\nStart of challenge: ${DateFormat("MMMM d, y").format(DateTime.parse(latestChallenge["creationDate"]))} at 12:00 AM\n\nDeadline of challenge: ${DateFormat("MMMM d, y").format(deadline!)} at 11:59 PM,",
                              "Go to Challenges",
                              "null",
                              false,
                              (context) => router.push('/workout/challenges'),
                              (context) => router.push('/workout/challenges'),
                            );
                          } 
                          else if (pendingChallenge && latestChallenge["fromUserid"] == myUserID){
                            ConfirmHelper.showPlainActionDialog(
                              context, 
                              "Pending Challenge", 
                              "You have a pending challenge with $userName.\n\nStart of challenge: ${DateFormat("MMMM d, y").format(DateTime.parse(latestChallenge["creationDate"]))} at 12:00 AM\n\nDeadline of challenge: ${DateFormat("MMMM d, y").format(deadline!)} at 11:59 PM,",
                              "Cancel Challenge",
                              "null",
                              false,
                              (context) => cancelChallenge(),
                              (context) => cancelChallenge()
                            );
                          }
                          else if (pendingChallenge && latestChallenge["fromUserid"] == userId){
                            ConfirmHelper.showPlainActionDialog(
                              context, 
                              "Pending Challenge", 
                              "You have a pending challenge from $userName.\n\nStart of challenge: ${DateFormat("MMMM d, y").format(DateTime.parse(latestChallenge["creationDate"]))} at 12:00 AM\n\nDeadline of challenge: ${DateFormat("MMMM d, y").format(deadline!)} at 11:59 PM,",
                              "Reject",
                              "Accept",
                              true,
                              (context) => rejectChallenge(),
                              (context) => acceptChallenge()
                            );
                          }
                          else {
                            ConfirmHelper.showChallengeDialog(context, (context) => selectDeadline());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.01,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isLoadingCha ? 0.0 : 1.0, 
                              child: Text(
                                ongoingChallenge ? 
                                "Current Challenge"
                                : (pendingChallenge ? 
                                  "Pending Challenge"
                                  : "Challenge"
                                  ),
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.035, 
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isLoadingCha)
                            SizedBox(
                              height: screenWidth * 0.045, 
                              width: screenWidth * 0.045, 
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(51, 51, 51, 1),
                                strokeWidth: 2.5,
                              ),
                            ),
                          ]  
                        ),
                      ) : 
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Challenge",
                            style: TextStyle(
                              color: Color.fromARGB(255, 121, 119, 119),
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight*0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isPending) ElevatedButton(
                          onPressed: () {cancelRequest();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isLoadingFr ? 0.0 : 1.0, 
                                child: Text(
                                  "Cancel Friend Request",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: screenWidth * 0.035, 
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isLoadingFr)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ]  
                          ),
                        )  
                        else if (isFriends) ElevatedButton(
                          onPressed: () {unFriend();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isLoadingFr ? 0.0 : 1.0, 
                                child: Text(
                                  "Unfriend",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'Roboto',
                                    fontSize: screenWidth * 0.035, 
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isLoadingFr)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ]  
                          ),
                        )
                        else if (hasReceived) ElevatedButton(
                          onPressed: () {acceptRequest();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isLoadingAccFr ? 0.0 : 1.0, 
                                child: Row(
                                  children: [
                                    Text(
                                      "Accept Friend",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontFamily: 'Roboto',
                                        fontSize: screenWidth * 0.035, 
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isLoadingAccFr)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ]  
                          ),
                        )
                        else ElevatedButton(
                          onPressed: () {addFriend();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isLoadingFr ? 0.0 : 1.0, 
                                child: Text(
                                  "Add as friend",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: screenWidth * 0.035, 
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isLoadingFr)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ]  
                          ),
                        ), 
                        if (hasReceived) SizedBox(width: screenWidth*0.03),
                        if (hasReceived) ElevatedButton(
                          onPressed: () {rejectRequest();},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.01,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.1, screenHeight * 0.01),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: isLoadingRejFr ? 0.0 : 1.0, 
                                child: Row(
                                  children: [
                                    Text(
                                      "Reject Friend",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'Roboto',
                                        fontSize: screenWidth * 0.035, 
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isLoadingRejFr)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ]  
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight*0.02, horizontal: screenWidth*0.05),
                      child: AspectRatio(
                        aspectRatio: 1.1, 
                        child: BarChartWidget(
                          title: "Weekly Steps",
                          workoutData: sessions,
                        )
                      )
                    ),
                  )
                ],
              );
            }
          }
      )
    );
  }
}
