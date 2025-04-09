// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:intl/intl.dart';

class WorkoutChallengesPage extends StatefulWidget {
  const WorkoutChallengesPage({super.key});

  @override
  State<WorkoutChallengesPage> createState() => _WorkoutChallengesPageState();
}

class _WorkoutChallengesPageState extends State<WorkoutChallengesPage> {
  // late BuildContext _currentContext;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _currentContext = context;
  // }

  late Future gettingChallenges;
  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> challenges = [];
  String? myUserID;
  List<Map<String, dynamic>> users = [];

  Future getFriendActivity() async {
    var response = await ApiService().getFriendActivity();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body)["activities"];
      setState(() {
        challenges = List<Map<String, dynamic>>.from(data); 
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
  
  Future getUserId() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    setState(() {
      myUserID = data["userid"];
    });
  }

  Future getWorkout() async {
    var response = await ApiService().getWorkout(myUserID);
    if (response.statusCode == 200){
      var data = jsonDecode(response.body)["workouts"];
      setState(() {
        sessions = List<Map<String, dynamic>>.from(data);
      }); 
    }
  }

  void filterFriends() {
    Map<String, String> userMap = {
      for (var user in users) user["userid"] as String: user["accountname"] as String
    };

    for (var activity in challenges) {
      String toUserId = activity["toUserid"];
      String fromUserId = activity["fromUserid"];
      activity["friendName"] = toUserId == myUserID ? userMap[fromUserId] : userMap[toUserId];
      activity["friendId"] = toUserId == myUserID ? fromUserId : toUserId;
    }

    challenges = challenges.where((activity) =>
      activity["activity"] == "CHA" &&
      (activity["status"] == "ONG" ||
      activity["status"] == "FIN")
    ).toList();

    challenges.sort((a, b) => DateTime.parse(b["creationDate"]).compareTo(DateTime.parse(a["creationDate"])));
  }

  Future setup() async {
    await getUserId();
    await getAllUsers();
    await getFriendActivity();
    await getWorkout();
    filterFriends();
  }

  @override
  void initState() {
    super.initState();
    gettingChallenges = setup();
  }
  
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: gettingChallenges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
              color: Color.fromRGBO(51, 51, 51, 1),
              ) 
            ); 
          } else if (snapshot.hasError) {
              return Center(child: Text("Error loading workout challenges"));
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.07, left: screenWidth * 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Challenges",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){ConfirmHelper.showResultDialog(context, "Challenge your friend one on one and see who has the most steps taken by the end of your challenge.\nPerson with the most steps by the end of your challenge wins!\nSteps will be counted from 12:00 AM on the challenge start date until 11:59 PM on the challenge end date.", "Info");},
                            icon: Icon(
                              Icons.info,
                              color: Colors.black87,
                              size: screenWidth * 0.07,
                            ),
                          ),
                          IconButton(
                            onPressed: (){router.push("/social");},
                            icon: Icon(
                              Icons.add_circle_rounded,
                              color: Colors.black87,
                              size: screenWidth * 0.07,
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
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: screenHeight * 0.01),
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      var item = challenges[index];
                      String creationDate = DateFormat("MMMM d").format(DateTime.parse(item["creationDate"]).toUtc().add(Duration(hours: 8)));
                      String deadline = DateFormat("MMMM d").format(DateTime.parse(item["deadline"]).toUtc().add(Duration(hours: 8)));
                      DateTime startDate = DateTime.parse(item["creationDate"]);
                      DateTime endDate = DateTime.parse(item["deadline"]);

                      Future<Map<String, dynamic>> prepareChallengeData() async {
                        List<Map<String, dynamic>> friendSessions = await ApiService().getWorkout(item["friendId"]).then((response) {
                          if (response.statusCode == 200) {
                            var data = jsonDecode(response.body)["workouts"];
                            return List<Map<String, dynamic>>.from(data);
                          }
                          return [];
                        });

                        List filteredWorkouts = sessions.where((workout) {
                          final creationDate = DateTime.parse(workout["creationDate"]);
                          final creationDateOnly = DateTime(creationDate.year, creationDate.month, creationDate.day);

                          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
                          final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

                          return (creationDateOnly.isAtSameMomentAs(startDateOnly) ||
                                  creationDateOnly.isAtSameMomentAs(endDateOnly) ||
                                  (creationDateOnly.isAfter(startDateOnly) && creationDateOnly.isBefore(endDateOnly)));
                        }).toList();

                        int totalSteps = filteredWorkouts.fold<int>(0, (sum, workout) => sum + (workout["steps"] as int));

                        // Filter friend's sessions
                        List friendFilteredWorkouts = friendSessions.where((workout) {
                          final creationDate = DateTime.parse(workout["creationDate"]);
                          final creationDateOnly = DateTime(creationDate.year, creationDate.month, creationDate.day);

                          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
                          final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

                          return (creationDateOnly.isAtSameMomentAs(startDateOnly) ||
                                  creationDateOnly.isAtSameMomentAs(endDateOnly) ||
                                  (creationDateOnly.isAfter(startDateOnly) && creationDateOnly.isBefore(endDateOnly)));
                        }).toList();

                        int friendTotalSteps = friendFilteredWorkouts.fold<int>(0, (sum, workout) => sum + (workout["steps"] as int));

                        String subtitleText;
                        String titleText;
                        Icon icon;

                        if (item["status"] == "ONG") {
                          subtitleText = "Your steps: $totalSteps";
                          titleText = "Vs. ${item["friendName"]}";
                          icon = Icon(Icons.timelapse_rounded, size: screenWidth * 0.1);
                        } else {
                          if (friendTotalSteps > totalSteps) {
                            subtitleText = "You lost by: ${friendTotalSteps-totalSteps}";
                            titleText = "${item["friendName"]} won";
                            icon = Icon(Icons.close, size: screenWidth * 0.1);
                          } else if (totalSteps > friendTotalSteps) {
                            subtitleText = "You won by: ${totalSteps-friendTotalSteps}";
                            titleText = "You won vs. ${item["friendName"]}";
                            icon = Icon(Icons.check, size: screenWidth * 0.1);
                          } else {
                            subtitleText = "Your steps: $totalSteps";
                            titleText = "Tied with ${item["friendName"]}";
                            icon = Icon(Icons.horizontal_rule_rounded, size: screenWidth * 0.1);
                          }
                        }

                        return {
                          "titleText": titleText,
                          "subtitleText": subtitleText,
                          "icon": icon,
                          "totalSteps": totalSteps,
                          "friendTotalSteps": friendTotalSteps,
                          "creationDate": creationDate,
                          "deadline": deadline,
                        };
                      }

                      return FutureBuilder<Map<String, dynamic>>(
                        future: prepareChallengeData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                              color: Color.fromRGBO(51, 51, 51, 1),
                              ) 
                            ); 
                          }
                          final data = snapshot.data!;
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
                            onTap: (){router.push('/social/profile/${item["friendId"]}/${item["friendName"]}');  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                              child: ListTile(
                                title: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Text(
                                    data["titleText"],
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
                                  child: data["icon"]
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min, 
                                  crossAxisAlignment: CrossAxisAlignment.end, 
                                  children: [
                                    Text(
                                      "Start: $creationDate",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        fontSize: screenWidth * 0.03,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                    Text(
                                      "End: $deadline",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        fontSize: screenWidth * 0.03,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, 
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(
                                      data["subtitleText"],
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenWidth * 0.038,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                    }
                )
                )
              ]
            );
          }
        }
      )
    );
  }
}