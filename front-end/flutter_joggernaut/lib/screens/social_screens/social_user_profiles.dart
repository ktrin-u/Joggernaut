import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/step_chart.dart';

class SocialUserProfilePage extends StatefulWidget {
  final String name; 

  const SocialUserProfilePage({
    super.key, 
    required this.name
  });


  @override
  State<SocialUserProfilePage> createState() => _SocialUserProfilePageState();
}

class _SocialUserProfilePageState extends State<SocialUserProfilePage> {
  final List<int> stepsPerDay = [1, 2, 3, 4, 5, 6, 7]; 

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
              Container(
                width: screenWidth*0.23,
                height: screenWidth*0.23,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),  
              SizedBox(width: screenWidth*0.04),
              Text(
                widget.name,
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
            ElevatedButton(
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
                "Invite",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontSize: screenWidth * 0.035, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: screenWidth*0.03),
            ElevatedButton(
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
                "Poke",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontSize: screenWidth * 0.035, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: screenWidth*0.03),
            ElevatedButton(
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
                "Add as friend",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontSize: screenWidth * 0.035, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
                    "70 kg",
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
                    "165 cm",
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
                    "2001-10-10",
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
            "Jeremy's progress as of last week:",
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
