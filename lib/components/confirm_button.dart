import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;

  const ConfirmButton({super.key, required this.onTap, required String buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: const Color(0xff114232),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 150,
        height: 50,
        child: const Center(
          child: Text(
            "Confirm",
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