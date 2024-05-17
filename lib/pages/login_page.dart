import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/components/my_button.dart';
import 'package:parking/components/my_textfield.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String> signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      return "Login successful";
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        return "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        return "Wrong password provided.";
      } else {
        return "Login failed. Please try again.";
      }
    } catch (e) {
      // Handle other exceptions
      return "An error occurred. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 80,),
              const Text(
                'SANTOS\nPARKING',
                style: TextStyle(
                  color: Color(0xff114232),
                  fontSize: 40,
                  fontFamily: 'ReadexPro',
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40,),
              
              Container(
                width: 340,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 167, 165, 165),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25,),
                    const Text(
                      'WELCOME!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontFamily: 'ReadexPro',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    const SizedBox(height: 25,),
                    MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                    const SizedBox(height: 30,),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 25,),
                    MyButton(
                      onTap: () async {
                        String result = await signUserIn();
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        ));
                      }, buttonText: 'Login',
                    ),
                    const SizedBox(height: 30,),
                  ],
                ),
              ),

            ],
            
          ),
        ),
      ),
    );
  }
}