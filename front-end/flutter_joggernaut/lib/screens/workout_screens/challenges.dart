// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';
import 'package:intl/intl.dart';

class WorkoutChallengesPage extends StatefulWidget {
  const WorkoutChallengesPage({super.key});

  @override
  State<WorkoutChallengesPage> createState() => _WorkoutChallengesPageState();
}

class _WorkoutChallengesPageState extends State<WorkoutChallengesPage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  late Future gettingWorkout;
  List<Map<String, dynamic>> sessions = [];
  TextEditingController stepsController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  bool isLoadingUpdate = false;

  void saveWorkout(item, workoutID){
    InputHelper.showWorkoutDialog(
      _currentContext, 
      "Update Session", 
      stepsController, 
      caloriesController, 
      (currentContext) => updateWorkout(item, workoutID)
    );
  }

  Future updateWorkout(item, workoutID) async {
    setState(() {
      isLoadingUpdate = true;
    });
    var response = await ApiService().updateWorkout(workoutID, stepsController.text, caloriesController.text);
    if (response.statusCode == 201){
      setState(() {
        getWorkout();
      });
      ConfirmHelper.showResultDialog(_currentContext, "Workout session updated successfully!", "Success");
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
      setState(() {
        isLoadingUpdate = false;
      });
    }
  }
  
  Future getWorkout() async {
    var response = await ApiService().getWorkout();
    if (response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        sessions = List<Map<String, dynamic>>.from(data);
        sessions.sort((a, b) => DateTime.parse(b["creationDate"]).compareTo(DateTime.parse(a["creationDate"])));
      });
    }
    setState(() {
      isLoadingUpdate = false;
    });
  }

  Future setup() async {
    await getWorkout();
  }

  @override
  void initState() {
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
                          if (isLoadingUpdate)
                          Padding(
                            padding: EdgeInsets.only(right: screenWidth*0.03),
                            child: SizedBox(
                              height: screenWidth * 0.09, 
                              width: screenWidth * 0.09, 
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(51, 51, 51, 1),
                                strokeWidth: 2.5,
                              ),
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
                    itemCount: sessions.length, 
                    itemBuilder: (context, index) {
                      var item = sessions[index];
                      var creationDate =  DateFormat("MMMM d").format(DateTime.parse(item["creationDate"]).toUtc().add(Duration(hours: 8)));
                      var lastUpdate =  DateFormat("MMMM d, h:mm a").format(DateTime.parse(item["lastUpdate"]).toUtc().add(Duration(hours: 8)));
                      
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
                            onTap: (){saveWorkout(item, item["workoutid"]);},
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                              child: ListTile(
                                title: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Text(
                                    creationDate,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      fontSize: screenWidth * 0.04,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                                leading: Icon(
                                  Icons.fitness_center,
                                  size: screenWidth*0.1,
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min, 
                                  crossAxisAlignment: CrossAxisAlignment.end, 
                                  children: [
                                    Text(
                                      "Last Updated:",
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        fontSize: screenWidth * 0.03,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                    Text(
                                      lastUpdate,
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
                                        "Steps: ${item["steps"]}",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenWidth * 0.035,
                                          color: Color.fromRGBO(51, 51, 51, 1),
                                        ),
                                      ),
                                      Text(
                                        "Calories: ${item["calories"]}",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenWidth * 0.035,
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