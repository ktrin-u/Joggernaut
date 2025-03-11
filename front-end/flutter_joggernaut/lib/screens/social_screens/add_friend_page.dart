import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/routes.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final searchController = TextEditingController();

  List<String> names = [
    "Sean McLoughlin",
    "Lance Andres",
    "Andri Crisostomo",
    "Gelo De Leon",
    "Rafa Jimenez",
    "Kevin Trinidad",
    "Hello World"
  ];

  List<String> filteredNames = []; 

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNames = [];
      } else {
        filteredNames = names
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      }
    });
  }

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
                "Add Friend",
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
        Padding(
          padding: EdgeInsets.fromLTRB(screenWidth*0.06, screenHeight*0.01, screenWidth*0.06, screenHeight*0.01),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1), 
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onSubmitted: (value) {
                filterSearch(value); 
              },
              decoration: InputDecoration(
                hintText: "Search a new friend",
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
                 prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.001, horizontal: screenWidth * 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide(color: Colors.transparent), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), 
                  borderSide: BorderSide(color: Colors.transparent), 
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 0, bottom: screenHeight*0.01),
            itemCount: filteredNames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth*0.07, vertical: screenHeight*0.001),
                child: InkWell(
                  onTap: (){router.push('/social/profile/${filteredNames[index]}');},
                  borderRadius: BorderRadius.circular(50), 
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth*0.03, vertical: screenHeight*0.01),
                    child: Row(
                      children: [
                        Container(
                          width: screenWidth*0.17,
                          height: screenWidth*0.17,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),  
                        SizedBox(width: screenWidth*0.04),
                        Text(
                          filteredNames[index],
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: screenWidth * 0.05,
                            color: Colors.black87,
                          ),
                        ),
                      ],
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