import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';
import 'package:go_router/go_router.dart';

class AdminUserProfilesPage extends StatefulWidget {
  const AdminUserProfilesPage({super.key});

  @override
  State<AdminUserProfilesPage> createState() => _AdminUserProfilesPageState();
}

class _AdminUserProfilesPageState extends State<AdminUserProfilesPage> {

  TextEditingController emailController = TextEditingController();

  Future banAccount () async{
    await ApiService().banAccount(emailController.text);
  }

  Future unbanAccount () async{
    await ApiService().unbanAccount(emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.07, left: screenWidth*0.08, right: screenWidth*0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: (){
                    GoRouter.of(context).pop();
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
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight*0.005),
              child: Text(
                "Users",
                style: TextStyle(
                  fontFamily: 'Big Shoulders Display',
                  fontSize: screenWidth * 0.13,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(51, 51, 51, 1)
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight*0.02),
              child: ListView(
                padding: EdgeInsets.zero, 
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.005),
                    child: _buildMenuItem("Unban User", screenWidth, screenHeight, Icon(Icons.key_rounded), (){InputHelper.showInputDialog(context, "Unban User", "Enter user's email address", emailController, unbanAccount, TextInputType.emailAddress);}, Color.fromRGBO(51, 51, 51, 1))
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.005),
                    child: _buildMenuItem("Ban User", screenWidth, screenHeight, Icon(Icons.delete_forever, color: Colors.red), (){InputHelper.showInputDialog(context, "Ban User", "Enter user's email address", emailController, banAccount, TextInputType.emailAddress);}, Colors.red),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider()),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}

Widget _buildMenuItem(String title, double screenWidth, double screenHeight, Icon icon, Function call, Color color) {
  return Column(
    children: [
      ListTile(
        title: Text(
          title, 
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.04,
            color: color
            )
          ),
        trailing: Icon(Icons.chevron_right, color: color),
        leading: icon,
        onTap: () {
          call();
        },
      ),
    ],
  );
}