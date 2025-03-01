import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  Future logout(context) async {
    await AuthService().logout();
    router.goNamed('landingpage');
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.07),
            child: Text(
              "Admin",
              style: TextStyle(
                fontFamily: 'Big Shoulders Display',
                fontSize: screenWidth * 0.13,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(51, 51, 51, 1)
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.01),
          _buildMenuItem("User Profiles", screenWidth, screenHeight, Icon(Icons.account_circle_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){router.push('/admin/users');}, ),
          _buildMenuItem("Feedback and Support", screenWidth, screenHeight, Icon(Icons.feedback_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Progress Monitoring", screenWidth, screenHeight, Icon(Icons.monitor_heart_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          Divider(),
          _buildMenuItem("Workout Plan", screenWidth, screenHeight, Icon(Icons.check_box, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Game Content", screenWidth, screenHeight, Icon(Icons.games_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Goals and Achievements", screenWidth, screenHeight, Icon(Icons.star, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Scheduling", screenWidth, screenHeight, Icon(Icons.schedule, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          Divider(),
          _buildMenuItem("Data Integration", screenWidth, screenHeight, Icon(Icons.data_thresholding, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Analytics", screenWidth, screenHeight, Icon(Icons.analytics, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Notifications", screenWidth, screenHeight, Icon(Icons.notification_important, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          Divider(),
          _buildMenuItem("Log out", screenWidth, screenHeight, Icon(Icons.logout, color: Color.fromRGBO(51, 51, 51, 1)), () => logout(context)),
        ],
      ),
    );
  }
}



Widget _buildMenuItem(String title, double screenWidth, double screenHeight, Icon icon, Function call) {
  return Column(
    children: [
      ListTile(
        title: Text(
          title, 
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.04,
            color: Color.fromRGBO(51, 51, 51, 1)
            )
          ),
        trailing: Icon(Icons.chevron_right, color: Colors.black54),
        leading: icon,
        onTap: () {
          call();
        },
      ),
    ],
  );
}