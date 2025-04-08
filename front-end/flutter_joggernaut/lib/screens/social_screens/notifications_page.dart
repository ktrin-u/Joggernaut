import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future gettingNotifications;
  String formatTimeAgo(Duration difference) {
    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} seconds ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${(difference.inDays / 7).floor()} weeks ago";
    }
  }
  String? myUserID;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> receivedRequests = [];
  List<Map<String, dynamic>> friendActivities = [];

  Future getUserId() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    setState(() {
      myUserID = data["userid"];
    });
  }

  Future getPendingFriends() async {
    var response = await ApiService().getPendingFriends();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        receivedRequests = List<Map<String, dynamic>>.from(data["received"]); 
      }); 
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

  Future getAllUsers() async {
    var response = await ApiService().getAllUsers();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(data["users"]); 
      });
    }
  }

  void filterFriends() {
    Map<String, String> userMap = {
      for (var user in users) user["userid"] as String: user["accountname"] as String
    };
    DateTime now = DateTime.now();
    for (var activity in friendActivities) {
      String toUserId = activity["toUserid"];
      String fromUserId = activity["fromUserid"];
      activity["friendName"] = toUserId == myUserID ? userMap[fromUserId] : userMap[toUserId];
      activity["friendId"] = toUserId == myUserID ? fromUserId : toUserId;

      DateTime creationDate = DateTime.parse(activity["creationDate"]);
      Duration difference = now.difference(creationDate);
      activity["timeAgo"] = formatTimeAgo(difference);
    }

    for (var request in receivedRequests) {
      String toUserId = request["toUserid"];
      String fromUserId = request["fromUserid"];
      request["friendName"] = toUserId == myUserID ? userMap[fromUserId] : userMap[toUserId];

      DateTime creationDate = DateTime.parse(request["creationDate"]);
      Duration difference = now.difference(creationDate);
      request["timeAgo"] = formatTimeAgo(difference);
    }

    friendActivities.removeWhere((activity) =>
      (activity["status"] == "CAN") ||
      (activity["activity"] == "CHA" && activity["status"] == "REJ" && activity["fromUserid"] == activity["friendId"])  ||
      (activity["activity"] == "CHA" && activity["status"] == "PEN" && activity["fromUserid"] == myUserID)
    );

    friendActivities.sort((a, b) => DateTime.parse(b["creationDate"]).compareTo(DateTime.parse(a["creationDate"])));
    receivedRequests.sort((a, b) => DateTime.parse(b["creationDate"]).compareTo(DateTime.parse(a["creationDate"])));
  }

  Future setup() async {
    await getUserId();
    await getAllUsers();
    await getPendingFriends();
    await getFriendActivity();
    filterFriends();
  }

  @override
  void initState(){
    super.initState();
    gettingNotifications = setup();

  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: gettingNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
              color: Color.fromRGBO(51, 51, 51, 1),
              ) 
            ); 
          } else if (snapshot.hasError) {
              return Center(child: Text("Error loading notifications"));
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.04, left: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Notifications",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: (){router.pop();},
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black87,
                          size: screenWidth * 0.07,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: screenHeight * 0.01),
                    itemCount: receivedRequests.length + friendActivities.length, 
                    itemBuilder: (context, index) {
                      bool isRequest = index < receivedRequests.length;
                      var item = isRequest ? receivedRequests[index] : friendActivities[index - receivedRequests.length]; 
                      Icon? icon;
                      var friendID = item["fromUserid"] == myUserID ? item["toUserid"] : item["fromUserid"];
                      String titleText;
                      String subtitleText;
                      if (isRequest) {
                        icon = Icon(
                          Icons.people,
                          size: screenWidth*0.1,
                        );
                        titleText = "${item["friendName"]}";
                        subtitleText = "sent you a friend request";
                      } else {
                        if (item["activity"] == "CHA") {
                          icon = Icon(
                            Icons.handshake_rounded,
                            size: screenWidth*0.1,
                          );
                          if (item["status"] == "EXP" && item["toUserid"] == myUserID) {
                            titleText = "${item["friendName"]}'s";
                            subtitleText = "challenge has expired!";
                          } else if (item["status"] == "EXP" && item["fromUserid"] == myUserID) {
                            titleText = "Your";
                            subtitleText = "challenge with ${item["friendName"]} has expired!";
                          } else if (item["status"] == "ONG") {
                            titleText = "Challenge Accepted";
                            subtitleText = "You have an ongoing challenge with ${item["friendName"]}";
                          } else if (item["status"] == "REJ") {
                            titleText = "Challenge Rejected";
                            subtitleText = "Your challenge to ${item["friendName"]} was rejected";
                          } else if (item["status"] == "FIN") {
                            titleText = "Your";
                            subtitleText = "challenge with ${item["friendName"]} has finished";
                          } else { 
                            titleText = "${item["friendName"]}";
                            subtitleText = "challenged you!";
                          }
                      
                        } else {
                          icon = Icon(
                            Icons.touch_app_rounded,
                            size: screenWidth*0.1,
                          );
                          titleText = "${item["friendName"]}";
                          subtitleText = "poked you!";
                        }
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.0075,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              if (item["activity"] == "CHA" && ((item["status"] == "ONG") || (item["status"] == "FIN"))){
                                router.push('/workout/challenges');
                              }
                              else {
                                router.push('/social/profile/$friendID/${item["friendName"]}');  
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                              child: ListTile(
                                title: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Text(
                                    titleText,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      fontSize: screenWidth * 0.04,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                                leading: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.01),
                                  child: icon
                                ),
                                trailing: Text(
                                  item["timeAgo"], 
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    fontSize: screenWidth * 0.03,
                                    color: Color.fromRGBO(51, 51, 51, 1),
                                  )
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Text(
                                    subtitleText, 
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      fontSize: screenWidth * 0.035,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]
            );
          }
        }
      )
    );
  }
}