import 'package:flutter/material.dart';
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ 
        Material(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 2,
          child: InkWell(
            onTap: (){},
            customBorder: CircleBorder(),
            splashColor: Colors.black12,
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Icon(
                icon, 
                size: 30, 
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ],
    );
  }
}