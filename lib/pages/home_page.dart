import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parking/services/firestore.dart';
import 'package:parking/components/time_button.dart';
import 'package:parking/components/confirm_button.dart';
import 'package:parking/pages/info_page.dart';
import 'package:parking/pages/auth_page.dart';
// Import the FirestoreServices class
class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final FirestoreServices firestoreService = FirestoreServices();

  final arrivalController = TextEditingController();
  final departureController = TextEditingController();
  
  String userType = "";

  Future<bool> checkUserReservation() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isReserve = (await FirebaseFirestore.instance.collection('User').doc(user.uid).get()).get('reserve') as bool;
      return isReserve;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error checking user reservation: $e');
    }
  }
  return false; // Default to false if there's an error or user is null
}
  
  

  @override
  void initState() {
    super.initState();
    FirestoreServices().fetchUserType(user.uid).then((type) {
      setState(() {
        userType = type;
      });
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(actions: [
          IconButton(
            onPressed: () {
              AuthPage.logoutUser();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthPage()));
              },
            icon: const Icon(Icons.logout)
          )],),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              const Text(
                'RESERVE NOW!',
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
                    StreamBuilder<int>(
                      stream: firestoreService.getSlots(), 
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 40,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        else if (snapshot.hasData){
                          return Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }
                        else {
                          return const Text(
                            '0/33',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w400,
                            )
                          );
                        }
                      } 
                    ),
                    const Text(
                      'Vacancies',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'ReadexPro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 25,),
                    const Text(
                      'Enter expected time of ARRIVAL',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'ReadexPro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    TimeButton(
                      buttonText: 'Pick me',
                      onTimePicked: (TimeOfDay time) {
                        arrivalController.text = time.format(context);
                      },
                    ),
                    const SizedBox(height: 40,),
                    const Text(
                      'Enter expected time of DEPARTURE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'ReadexPro',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 5,),
                    TimeButton(
                      buttonText: 'Pick me',
                      onTimePicked: (TimeOfDay time) {
                        departureController.text = time.format(context);
                      },
                    ),
                    const SizedBox(height: 30,),
                    ConfirmButton(
                      onTap: () async {
                        String result = await firestoreService.reserveUsers(user.uid,arrivalController.text,departureController.text, true
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.green,
                        )
                        );
                      // await Future.delayed(Duration(seconds: 3));
                      if (result.contains('successful')) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(
                          ),
                        )
                      );
                    }
                  },
                  buttonText: 'Reserve Now',
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
