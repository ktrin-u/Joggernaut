// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';
import 'package:intl/intl.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Future gettingWorkout;
  int? steps;
  int? calories;
  int? workoutID;
  String? creationDate;
  String? lastUpdate;
  List<(DateTime, int)> sessions = [];
  List<int> weeklySteps = List.filled(7, 0);

  Future getWorkout() async {
    var response = await ApiService().getWorkout();
    if (response.statusCode == 200){
      if (response.body == "[]"){
        setState(() {
          steps = 0;
          calories = 0;
        });
        return;
      }
      List<dynamic> jsonData = jsonDecode(response.body);
      jsonData = jsonData.length > 7 ? jsonData.sublist(jsonData.length - 7) : jsonData;
      jsonData.sort((a, b) => DateTime.parse(a["creationDate"]).compareTo(DateTime.parse(b["creationDate"])));
      Map<String, dynamic> data = jsonData.last;
      
      setState(() {
        steps = data["steps"];
        calories = data["calories"];
        workoutID = data["workoutid"];
        creationDate = DateFormat("MMMM d").format(DateTime.parse(data["creationDate"]).toUtc().add(Duration(hours: 8)));
        lastUpdate = DateFormat("MMMM d, h:mm a").format(DateTime.parse(data["lastUpdate"]).toUtc().add(Duration(hours: 8)));
        sessions = jsonData.map((w) => (
          DateTime.parse(w["lastUpdate"]).toUtc().add(Duration(hours: 8)), (w["steps"] as num).toInt()  
        )).toList();
      });

    }
    else if (response.statusCode == 404){
      setState(() {
        steps = 0;
        calories = 0;
      });
    }
  }

  Future setup() async{
    await getWorkout();
  }

  @override
  void initState(){
    super.initState();
    gettingWorkout = setup();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: gettingWorkout,
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
                  padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.07, left: screenWidth * 0.07),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline, 
                    textBaseline: TextBaseline.alphabetic, 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Workout",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){router.push('/workout/challenges');},
                            icon: Icon(
                              Icons.handshake_rounded,
                              color: Colors.black87,
                              size: screenWidth * 0.09,
                            ),
                          ),
                          IconButton(
                            onPressed: (){router.push('/workout/sessions');},
                            icon: Icon(
                              Icons.format_list_bulleted_add,
                              color: Colors.black87,
                              size: screenWidth * 0.09,
                            ),
                          ),
                        ],
                      ),
                    ]
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight*0.02, horizontal: screenWidth*0.05),
                  child: AspectRatio(
                    aspectRatio: 1.1, 
                    child: BarChartWidget(
                      title: "Weekly Steps",
                      workoutData: sessions,
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.07),
                  child: Row(
                    children: [
                      Text(
                        "Your Latest Session:",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontSize: screenWidth * 0.07, 
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.1, vertical: screenHeight*0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Steps:",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.06, 
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            steps!.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.08, 
                              fontWeight: FontWeight.w700,
                            ),  
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth*0.2),
                      Column(
                        children: [
                          Text(
                            "Calories:",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.06, 
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            calories!.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.08, 
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight*0.01),
                Text(
                  "Created: $creationDate",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  "Updated: $lastUpdate",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            );
          }
        }
      )
    );
  }
}