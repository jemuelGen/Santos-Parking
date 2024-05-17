import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTap;

  const MyButton({required this.onTap, required String buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Color(0xff114232),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 150,
        height: 60,
        child: Center(
          child: Text(
            "Log in",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ReadexPro',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}