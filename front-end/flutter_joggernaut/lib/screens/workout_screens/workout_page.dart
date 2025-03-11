import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
              weeklyData: [8, 10, 14, 15, 13, 10, 16], 
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
                        onPressed: (){},
                        iconSize: screenWidth*0.07,
                        icon: Icon(Icons.edit_square),
                        color: Color.fromRGBO(90, 155, 212, 1),
                      )
                    ],
                  ),
                  Text(
                    "7,744",
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
                        onPressed: (){},
                        iconSize: screenWidth*0.07,
                        icon: Icon(Icons.edit_square),
                        color: Color.fromRGBO(90, 155, 212, 1),
                      )
                    ],
                  ),
                  Text(
                    "3,025",
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                  backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05, vertical: screenHeight*0.001),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isLoading ? 0.0 : 1.0, 
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
                    if (isLoading)
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