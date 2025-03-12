// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';

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
  String? myUserID;
  List friendIDs = [];
  List<Map<String, dynamic>> pendingRequest = [];
  bool isPoking = false;
  bool isLoading = false;
  bool isFriends = false;
  bool isPending = false;
  bool hasReceived = false;
 

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
      isLoading = true;
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
      isLoading = false;
    });
  }

  Future unFriend() async {
    setState(() {
      isLoading = true;
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
      isLoading = false;
    });
  }

  Future cancelRequest() async {
    setState(() {
      isLoading = true;
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
      isLoading = false;
    });
  }

  Future acceptRequest() async {
    setState(() {
      isLoading = true;
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
      isLoading = false;
    });
  }

  Future rejectRequest() async {
    setState(() {
      isLoading = true;
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
      isLoading = false;
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

  Future setup() async {
    await getUserId();
    await getFriends();
    await getPendingFriends();
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
              return Center(child: Text("Error loading workout"));
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
                        // Container(
                        //   width: screenWidth*0.23,
                        //   height: screenWidth*0.23,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     color: Colors.white,
                        //   ),
                        // ),  
                        // SizedBox(width: screenWidth*0.04),
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
                      (isFriends) ? ElevatedButton(
                        onPressed: () {},
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
                        child: Text(
                          "Challenge",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Roboto',
                            fontSize: screenWidth * 0.035, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ) : Container(
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
                            "Invite",
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
                      (isFriends) ? ElevatedButton(
                        onPressed: () {ConfirmHelper.showConfirmDialog(context, "Are you sure you want to poke $userName?", (context) => pokeFriend());},
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
                              color:  Color.fromARGB(255, 121, 119, 119),
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth*0.03),
                      if (isPending)
                      ElevatedButton(
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
                              opacity: isLoading ? 0.0 : 1.0, 
                              child: Text(
                                "Cancel Request",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                  fontSize: screenWidth * 0.035, 
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isLoading)
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
                      else if (isFriends)
                      ElevatedButton(
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
                              opacity: isLoading ? 0.0 : 1.0, 
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
                            if (isLoading)
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
                      else if (hasReceived)
                      ElevatedButton(
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
                              opacity: isLoading ? 0.0 : 1.0, 
                              child: Row(
                                children: [
                                  Text(
                                    "Accept",
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
                            if (isLoading)
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
                      else
                      ElevatedButton(
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
                              opacity: isLoading ? 0.0 : 1.0, 
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
                            if (isLoading)
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
                      SizedBox(width: screenWidth*0.03),
                      if (hasReceived)
                      ElevatedButton(
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
                              opacity: isLoading ? 0.0 : 1.0, 
                              child: Row(
                                children: [
                                  Text(
                                    "Reject",
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
                            if (isLoading)
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth*0.1, vertical: screenHeight*0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Weight:",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.045, 
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "?? kg",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.05, 
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Height:",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.045, 
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "?? cm",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.05, 
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Birthday:",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.045, 
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "????-??-??",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.05, 
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight*0.01),
                    child: Text(
                      "$userName's progress as of last week:",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: screenWidth * 0.045, 
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight*0.02),
                      child: AspectRatio(
                        aspectRatio: 0.95, 
                        child: BarChartWidget(
                          title: "Weekly Steps",
                          weeklyData: [8, 10, 14, 15, 13, 10, 16], 
                          highlightDay: DateTime.now().weekday, 
                        )
                      )
                    )
                  )
                ],
              );
            }
          }
      )
    );
  }
}
