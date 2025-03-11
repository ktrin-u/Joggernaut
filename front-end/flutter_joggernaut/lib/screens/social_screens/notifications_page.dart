import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> names = [
    "Sean McLoughlin",
    "Lance Andres",
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.04, left: screenWidth * 0.07),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notifications",
                style: TextStyle(
                  fontFamily: 'Big Shoulders Display',
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: (){router.pop();},
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black87,
                  size: screenWidth * 0.07,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 0, bottom: screenHeight*0.01),
            itemCount: names.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.0075),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight*0.001),
                    child: ListTile(
                      title: Text(
                      "Jacob",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: screenWidth * 0.04,
                        color: Color.fromRGBO(51, 51, 51, 1)
                      ),
                      ),
                      leading: Container(
                        width: screenWidth*0.17,
                        height: screenWidth*0.17,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(245, 245, 245, 1),
                        ),
                      ), 
                      subtitle: Text(
                        "poked you",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: screenWidth * 0.035,
                          color: Color.fromRGBO(51, 51, 51, 1)
                        ),
                      ), 
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: (){},
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: screenWidth * 0.07,
                            ),
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: Icon(
                              Icons.check_circle,
                              color: Color.fromRGBO(90, 155, 212, 1),
                              size: screenWidth * 0.07,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                )
              );
            },
          ),
        ) 
      ]
    );
  }
}