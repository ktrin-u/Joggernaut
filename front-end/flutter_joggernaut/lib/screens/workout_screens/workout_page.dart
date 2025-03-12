// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  late Future gettingWorkout;
  bool isFirstWorkout = false;
  bool isLoadingUpdate = false;
  bool isLoadingAdd = false;
  int? steps;
  int? calories;
  int? workoutID;

  TextEditingController stepsController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();

  void _saveSteps(){
    setState(() {
      steps = int.tryParse(stepsController.text);
    });
  }
  
  void _saveCalories(){
    setState(() {
      calories = int.tryParse(caloriesController.text);
    });
  }

  void _addWorkout(){
    ConfirmHelper.showConfirmDialog(
      context, 
      "Are you sure you want to create your workout session?",
      (context) => _createWorkout()
    );
  }

  void _saveWorkout(){
    if (isFirstWorkout){
      ConfirmHelper.showResultDialog(_currentContext, "Please create a workout session first", "Failed");
    }
    else {
      ConfirmHelper.showConfirmDialog(
        context, 
        "Are you sure you want to update your workout session?",
        (context) => _updateWorkout()
      );
    }
  }

  Future _createWorkout() async {
    setState(() {
      isLoadingAdd = true;
    });
    var response = await ApiService().createWorkout(steps, calories);
    if (response.statusCode == 200){
      ConfirmHelper.showResultDialog(_currentContext, "Workout session created successfully!", "Success");
      setState(() {
        isFirstWorkout = false;
      });
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody["msg"];
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    getWorkout();
    setState(() {
      isLoadingAdd = false;
    });
  }

  Future _updateWorkout() async {
    setState(() {
      isLoadingUpdate = true;
    });
    var response = await ApiService().updateWorkout(workoutID, steps, calories);
    if (response.statusCode == 201){
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
    }
    getWorkout();
    setState(() {
      isLoadingUpdate = false;
    });
  }

  Future getWorkout() async {
    var response = await ApiService().getWorkout();
    if (response.statusCode == 200){
      if (response.body == "[]"){
        setState(() {
          steps = 0;
          calories = 0;
          isFirstWorkout = true;
          stepsController.text = steps!.toString();
          caloriesController.text = calories!.toString();
        });
        return;
      }
      List<dynamic> jsonData = jsonDecode(response.body);
      Map<String, dynamic> data = jsonData[0];

      setState(() {
        steps = data["steps"];
        calories = data["calories"];
        workoutID = data["workoutid"];
        stepsController.text = steps!.toString();
        caloriesController.text = calories!.toString();
      });
    }
    else if (response.statusCode == 404){
      setState(() {
        steps = 0;
        calories = 0;
        stepsController.text = steps!.toString();
        caloriesController.text = calories!.toString();
      });
    }
  }

  @override
  void initState(){
    super.initState();
    gettingWorkout = getWorkout();
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
                          Text(
                            "Weight: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.06, 
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "80 kg",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.05, 
                              fontWeight: FontWeight.w400,
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
                    aspectRatio: 0.95, 
                    child: BarChartWidget(
                      title: "Weekly Steps",
                      weeklyData: [0, 0, 0, 0, steps!, 0, 0], 
                      highlightDay: DateTime.now().weekday, 
                    )
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.07),
                  child: Row(
                    children: [
                      Text(
                        "Today you did:",
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
                          Row(
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
                              IconButton(
                                onPressed: (){
                                  InputHelper.showInputNumDialog(
                                    context, 
                                    "Steps", 
                                    "Enter the number of steps", 
                                    stepsController, 
                                    _saveSteps
                                  );
                                },
                                iconSize: screenWidth*0.07,
                                icon: Icon(Icons.edit_square),
                                color: Color.fromRGBO(90, 155, 212, 1),
                              )
                            ],
                          ),
                          Text(
                            steps!.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.08, 
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: screenWidth*0.1),
                      Column(
                        children: [
                          Row(
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
                              IconButton(
                                onPressed: (){
                                  InputHelper.showInputNumDialog(
                                    context, 
                                    "Calories", 
                                    "Enter the number of calories", 
                                    caloriesController, 
                                    _saveCalories,
                                  );
                                },
                                iconSize: screenWidth*0.07,
                                icon: Icon(Icons.edit_square),
                                color: Color.fromRGBO(90, 155, 212, 1),
                              )
                            ],
                          ),
                          Text(
                            calories!.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Roboto',
                              fontSize: screenWidth * 0.08, 
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {_addWorkout();},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05, vertical: screenHeight*0.001),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(screenWidth * 0.25, screenHeight * 0.045),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isLoadingAdd ? 0.0 : 1.0, 
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                            if (isLoadingAdd)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth*0.02),
                      ElevatedButton(
                        onPressed: () {_saveWorkout();},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05, vertical: screenHeight*0.001),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(screenWidth * 0.25, screenHeight * 0.045),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isLoadingUpdate ? 0.0 : 1.0, 
                              child: Text(
                                "Update",
                                style: TextStyle(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ),
                            if (isLoadingUpdate)
                              SizedBox(
                                height: screenWidth * 0.045, 
                                width: screenWidth * 0.045, 
                                child: CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                  strokeWidth: 2.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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