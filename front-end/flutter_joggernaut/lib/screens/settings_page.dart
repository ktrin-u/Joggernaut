import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
              "Settings",
              style: TextStyle(
                fontFamily: 'Big Shoulders Display',
                fontSize: screenWidth * 0.13,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(51, 51, 51, 1)
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.01),
          _buildMenuItem("Account", screenWidth, screenHeight, Icon(Icons.manage_accounts_rounded, color: Color.fromRGBO(51, 51, 51, 1)), () => router.push("/settings/account"), ),
          _buildMenuItem("Security and Privacy", screenWidth, screenHeight, Icon(Icons.lock_outline_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Language and Region", screenWidth, screenHeight, Icon(Icons.language_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          Divider(),
          _buildMenuItem("App Connection", screenWidth, screenHeight, Icon(Icons.key_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Display", screenWidth, screenHeight, Icon(Icons.mode_night_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Notifications", screenWidth, screenHeight, Icon(Icons.notifications, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Accessibility", screenWidth, screenHeight, Icon(Icons.switch_access_shortcut_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          Divider(),
          _buildMenuItem("Report a Problem", screenWidth, screenHeight, Icon(Icons.flag_circle_rounded, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Support", screenWidth, screenHeight, Icon(Icons.contact_support, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
          _buildMenuItem("Terms and Policies", screenWidth, screenHeight, Icon(Icons.policy, color: Color.fromRGBO(51, 51, 51, 1)), (){}),
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