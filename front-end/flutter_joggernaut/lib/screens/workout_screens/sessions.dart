// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';
import 'package:intl/intl.dart';

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late BuildContext _currentContext;

  TextEditingController stepsControllerCreate = TextEditingController();
  TextEditingController caloriesControllerCreate = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  late Future gettingWorkout;
  List<Map<String, dynamic>> sessions = [];
  bool isLoadingAdd = false;
  String? myUserID;

  Future getUserId() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    setState(() {
      myUserID = data["userid"];
    });
  }

  void _addWorkout(){
    InputHelper.showWorkoutDialog(
      _currentContext, 
      "Create New Session", 
      stepsControllerCreate, 
      caloriesControllerCreate, 
      (currentContext) => createWorkout(stepsControllerCreate.text, caloriesControllerCreate.text)
    );
  }

  Future createWorkout(steps, calories) async {
    setState(() {
      isLoadingAdd = true;
    });
    var response = await ApiService().createWorkout(steps, calories);
    if (response.statusCode == 201){
      setState(() {
        getWorkout();
      });
      ConfirmHelper.showResultDialog(_currentContext, "Workout session created successfully!", "Success");
    } 
    else {
      String errorMessage = "Please enter a valid integer for steps and calories";
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
      setState(() {
        isLoadingAdd = false;
      });
    }
  }

  Future updateWorkout(workoutID, steps, calories) async {
    if (checkWorkout(workoutID)){
      var response = await ApiService().updateWorkout(workoutID, steps, calories);
      if (response.statusCode == 201){
        setState(() {
          getWorkout();
        });
        ConfirmHelper.showResultDialog(_currentContext, "Workout session updated successfully!", "Success");
        return true;
      } 
      else {
        String errorMessage = "Please enter a valid integer for steps and calories";
        ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
        return false;
      }
    }
    else {
      ConfirmHelper.showResultDialog(_currentContext, "The workout session has already passed. You can only update workout sessions on the same day they were created.", "Session Passed");
      return false;
    }
  }
  
  Future getWorkout() async {
    var response = await ApiService().getWorkout(myUserID);
    if (response.statusCode == 200){
      var data = jsonDecode(response.body)["workouts"];
      setState(() {
        sessions = List<Map<String, dynamic>>.from(data);
        sessions.sort((a, b) => DateTime.parse(b["creationDate"]).compareTo(DateTime.parse(a["creationDate"])));
      });
    }
    setState(() {
      isLoadingAdd = false;
    });
  }

  bool checkWorkout(workoutid) {
    var item = sessions.firstWhere(
      (element) => element['workoutid'] == workoutid,
    );

    DateTime creationDate = DateTime.parse(item["creationDate"]).toUtc().add(Duration(hours: 8));
    DateTime today = DateTime.now().toUtc().add(Duration(hours: 8));
    bool isSameDate(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    return isSameDate(creationDate, today);
  } 

  Future setup() async {
    await getUserId();
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
              return Center(child: Text("Error loading workout sessions"));
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
                        "Sessions",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Opacity(
                            opacity: isLoadingAdd ? 0.0 : 1.0, 
                            child: IconButton(
                              onPressed: (){_addWorkout();},
                              icon: Icon(
                                Icons.add_circle_rounded,
                                color: Colors.black87,
                                size: screenWidth * 0.07,
                              ),
                            ),
                          ),
                          if (isLoadingAdd)
                          Padding(
                            padding: EdgeInsets.only(right: screenWidth*0.03),
                            child: SizedBox(
                              height: screenWidth * 0.07, 
                              width: screenWidth * 0.07, 
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
                      TextEditingController stepsController = TextEditingController();
                      TextEditingController caloriesController = TextEditingController();
                      
                      Future updatingWorkout() async{
                        setState(() {
                          item["isLoading"] = true;
                        });
                        var result = await updateWorkout(item["workoutid"], stepsController.text, caloriesController.text);
                        if (result == false){
                          setState(() {
                            item["isLoading"] = false;
                          });
                        }
                      }

                      void saveWorkout(){
                        if (checkWorkout(item["workoutid"])){
                          InputHelper.showWorkoutDialog(
                            _currentContext, 
                            "Update Session", 
                            stepsController, 
                            caloriesController, 
                            (currentContext) => updatingWorkout()
                          );
                        }
                        else {
                          ConfirmHelper.showResultDialog(_currentContext, "The workout session has already passed. You can only update workout sessions on the same day they were created.", "Session Passed");
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
                            onTap: (){saveWorkout();},
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
                                leading: (item["isLoading"] == true) ? Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: SizedBox(
                                    height: screenWidth * 0.1, 
                                    width: screenWidth * 0.1, 
                                    child: CircularProgressIndicator(
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ) : Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Icon(
                                    Icons.fitness_center,
                                    size: screenWidth*0.1,
                                  ),
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