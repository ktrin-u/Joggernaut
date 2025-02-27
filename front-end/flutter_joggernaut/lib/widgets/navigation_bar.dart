import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:go_router/go_router.dart';

class CustomNavigationBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const CustomNavigationBar(this.navigationShell, {super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late Future getStaff;
  bool isStaff = false;
  
  Future getIsStaff() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    setState(() {
      isStaff = data["is_staff"];
    });
  }

  @override
  void initState() {
    super.initState();
    getStaff = getIsStaff();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: getStaff,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
            color: Color.fromRGBO(51, 51, 51, 1),
            ) 
          ); 
        } else if (snapshot.hasError) {
            return Center(child: Text("Error loading navbar"));
        } else { 
          return BottomNavigationBar(
            currentIndex: widget.navigationShell.currentIndex,
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
              widget.navigationShell.goBranch(index, initialLocation: index == widget.navigationShell.currentIndex);
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
              ),
              if (isStaff) BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight *0.005, horizontal: screenWidth*0.005),
                  child: Icon(Icons.admin_panel_settings),
                ),
                label: "Admin",
              ) 
            ]
          );
        }
      }
    );
  }
}
