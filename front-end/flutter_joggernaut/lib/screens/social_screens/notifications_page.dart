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
  String? myUserID;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> requests = [];
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
      var data = jsonDecode(response.body);
      setState(() {
        friendActivities = List<Map<String, dynamic>>.from(data["activities"]); 
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

  void filterFriends () {
    List requestIDs = receivedRequests.map((friend) {
      return friend["fromUserid"] == myUserID ? friend["toUserid"] : friend["fromUserid"];
    }).where((id) => id != myUserID).toList();

    List friendIDs = friendActivities.map((friend) {
      return friend["fromUserid"] == myUserID ? friend["toUserid"] : friend["fromUserid"];
    }).where((id) => id != myUserID).toList();

    setState(() {
      requests = users
      .where((user) => requestIDs.contains(user["userid"]))
      .toList();

      friends = users
      .where((user) => friendIDs.contains(user["userid"]))
      .toList();
    });
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
              return Center(child: Text("Error loading workout"));
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
                    itemCount: requests.length + friends.length, 
                    itemBuilder: (context, index) {
                      bool isRequest = index < requests.length; 
                      var item = isRequest ? requests[index] : friends[index - requests.length]; 
                      String subtitleText = isRequest ? "sent you a friend request" : "poked you!"; 
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
                            onTap: (){router.push('/social/profile/${item["userid"]}/${item["accountname"]}');},
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                              child: ListTile(
                                title: Text(
                                  item["accountname"],
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    fontSize: screenWidth * 0.04,
                                    color: Color.fromRGBO(51, 51, 51, 1),
                                  ),
                                ),
                                leading: Container(
                                  width: screenWidth * 0.17,
                                  height: screenWidth * 0.17,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(245, 245, 245, 1),
                                  ),
                                ),
                                subtitle: Text(
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