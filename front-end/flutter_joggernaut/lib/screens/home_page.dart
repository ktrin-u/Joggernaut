import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import '../widgets/home_menu_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  bool isStaff = false;
  late Future name;

  Future logout(context) async {
    setState(() {
      isLoading = true;
    });

    await AuthService().logout();

    setState(() {
      isLoading = false;
    });
    
    router.goNamed('landingpage');
  }

  Future getName() async{
    var response = await ApiService().getUserInfo();
    var data = jsonDecode(response.body);
    String firstname = data["firstname"];
    String lastname = data["lastname"];
    setState(() {
      isStaff = data["is_staff"];
    });
    return firstname.isNotEmpty
      ? firstname[0].toUpperCase() + firstname.substring(1) +
      (lastname.isNotEmpty ? " ${lastname[0].toUpperCase()}." : "")
      : "User";
  }

  @override
  void initState() {
    super.initState();
    name = getName(); 
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(250, 243, 239, 1),
        body: FutureBuilder(
          future: name,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                color: Color.fromRGBO(51, 51, 51, 1),
                ) 
              ); 
            } else if (snapshot.hasError) {
                return Center(child: Text("Error loading user"));
            } else {
              return Center(
                child: SingleChildScrollView(
                  child: (
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome,",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w300,
                            color: Color.fromRGBO(51, 51, 51, 1),
                          ),
                        ),
                        Text(
                          snapshot.data,
                          style: TextStyle(
                            fontFamily: 'Big Shoulders Display',
                            fontSize: screenWidth * 0.13,
                            fontWeight: FontWeight.bold,
                            color: (!isStaff) ? Color.fromRGBO(90, 155, 212, 1) : Color.fromRGBO(75, 0, 130, 1),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Wrap(
                          spacing: screenWidth * 0.1,
                          alignment: WrapAlignment.center,
                          children: [
                            MenuButton(icon: Icons.fitness_center, label: "Workout", onTap: () => router.push('/workout')),
                            MenuButton(icon: Icons.videogame_asset, label: "Play", onTap: () => router.push('/game/my-characters')),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Wrap(
                          spacing: screenWidth * 0.1,
                          alignment: WrapAlignment.center,
                          children: [
                            MenuButton(icon: Icons.people, label: "Social", onTap: () => router.push('/social')),
                            MenuButton(icon: Icons.person, label: "Profile", onTap: () => router.push('/profile')),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        (isStaff) ? Wrap(
                          spacing: screenWidth * 0.1,
                          alignment: WrapAlignment.center,
                          children: [
                            MenuButton(icon: Icons.settings, label: "Settings", onTap: () => router.push('/settings')),
                            MenuButton(icon: Icons.admin_panel_settings, label: "Admin", onTap: () => router.push('/admin'))
                          ],
                        ) : Wrap(
                          spacing: screenWidth * 0.1,
                          alignment: WrapAlignment.center,
                          children: [
                            MenuButton(icon: Icons.settings, label: "Settings", onTap: () => router.push('/settings')),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.08),
                        ElevatedButton(
                          onPressed: () {
                            logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                            padding: EdgeInsets.symmetric( 
                              horizontal: screenWidth * 0.065, 
                              vertical: screenHeight * 0.008,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(screenWidth * 0.04, screenHeight * 0.01),
                          ),
                          child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: isLoading ? 0.0 : 1.0, 
                              child: Text(
                                "Log out",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
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
                    )
                  ),
                ),
              );
            }
          }
        ),
      ),
    );
  }
}