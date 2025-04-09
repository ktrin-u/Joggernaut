import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';

class LeaderboardsPage extends StatefulWidget {
  const LeaderboardsPage({super.key});

  @override
  State<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends State<LeaderboardsPage> {
  late Future gettingLeaderboards;
  List<dynamic> leaderboards = [];
  bool stepsLoading = false;
  bool attemptsLoading = false;
  String category = "Steps";

  Future getLeaderboards() async{
    var response = await ApiService().getLeaderboards(category.toLowerCase());
    if (response.statusCode == 200){
      var data = jsonDecode(response.body)["leaderboard"];
      setState(() {
        leaderboards = data;
      });
    }
  }

  void getSteps() async {
    setState(() {
      stepsLoading = true;
      category = "Steps";
    });
    await getLeaderboards();
    setState(() {
      stepsLoading = false;
    });
  }

  void getAttempts() async {
    setState(() {
      category = "Attempts";
      attemptsLoading = true;
    });
    await getLeaderboards();
    setState(() {
      attemptsLoading = false;
    });
  }

  @override
  void initState() {
    gettingLeaderboards = getLeaderboards();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: gettingLeaderboards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
              color: Color.fromRGBO(51, 51, 51, 1),
              ) 
            ); 
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading leaderboards"));
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.07, left: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Leaderboards",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.09,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){router.pop();},
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black87,
                              size: screenWidth * 0.05,
                            ),
                          ),                        
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider(thickness: 1.75, color: Colors.grey,)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: (){
                        getSteps();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: (category=="Steps") ? Color.fromRGBO(90, 155, 212, 1) : Colors.transparent
                      ),
                      child: Text(
                        "Steps",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: (category == "Steps") ? Colors.white : Colors.black87,
                        ),
                      ) 
                    ),
                    TextButton(
                      onPressed: (){
                        getAttempts();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        backgroundColor: (category=="Attempts") ? Color.fromRGBO(90, 155, 212, 1) : Colors.transparent
                      ),
                      child: Text(
                        "Game Attempts",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: (category == "Attempts") ? Colors.white : Colors.black87,
                        ),
                      ) 
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider(thickness: 1.75, color: Colors.grey,)),
                (stepsLoading || attemptsLoading) ? 
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight*0.1),
                  child: CircularProgressIndicator(
                    color: Colors.black87,
                    strokeWidth: 2.5,
                  ),
                ) : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: screenHeight * 0.01),
                    itemCount: leaderboards.length,
                    itemBuilder: (context, index) {
                      Color colorCard;

                      if (index == 0){
                        colorCard = Color.fromRGBO(255, 215, 0, 1);
                      } else if (index == 1){
                        colorCard = Color.fromRGBO(192, 192, 192, 1);
                      } else if (index == 2){
                        colorCard = Color.fromRGBO(205, 127, 50, 1);
                      } else {
                        colorCard = Colors.white;
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.005,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.zero,
                            color: colorCard,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                              child: ListTile(
                                title: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.02),
                                  child: Text(
                                    leaderboards[index][0],
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      fontSize: screenWidth * 0.045,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                                leading: Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.03),
                                  child: Text(
                                    (index+1).toString(),
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      fontSize: screenWidth * 0.045,
                                      color: Color.fromRGBO(51, 51, 51, 1),
                                    ),
                                  ),
                                ),
                                trailing: Text(
                                  "$category: ${leaderboards[index][1]}",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: screenWidth * 0.035,
                                    color: Color.fromRGBO(51, 51, 51, 1),
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