import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:go_router/go_router.dart';

class CustomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomNavigationBar(this.navigationShell, {super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: Color.fromRGBO(90, 155, 212, 1),
      unselectedItemColor: primaryBlack,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: screenWidth * 0.035,
        fontWeight: FontWeight.w700,
        color: Color.fromRGBO(51, 51, 51, 1),
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: screenWidth * 0.035,
        fontWeight: FontWeight.w700,
        color: Color.fromRGBO(51, 51, 51, 1),
      ),
      onTap: (index) {
        navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
      },
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005), 
            child: Icon(Icons.directions_run),
          ),
          label: "Workout",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005),
            child: Icon(Icons.sports_esports),
          ),
          label: "Game",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005),
            child: Icon(Icons.person),
          ),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005),
            child: Icon(Icons.people),
          ),
          label: "Social",
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005),
            child: Icon(Icons.settings),
          ),
          label: "Settings",
        )
      ],
    );
  }
}
