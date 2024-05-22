import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/pages/auth_page.dart';
import 'package:parking/pages/home_page.dart';
import 'package:parking/services/firestore.dart';
import 'package:parking/components/time_button.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final FirestoreServices parkingLotService = FirestoreServices();
  final User user = FirebaseAuth.instance.currentUser!;
  String arrival = '';
  String departure = '';

  @override
  void initState() {
    super.initState();
    getDepartureTime();
  }
  void getDepartureTime() async{
    String _fetchDeparture = await parkingLotService.fetchDepartureTime(user.uid);
    setState(() {
      departure = _fetchDeparture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: parkingLotService.departureTimeStream(user.uid),
      builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true){
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
                    const SizedBox(height: 80,),
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
                            'Reservation status',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 25,),
                          const Text(
                            'ARRIVAL',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          StreamBuilder<String?>(
                            stream: parkingLotService.fetchArrivalTime(user.uid),
                            builder: (context, snapshot) {
                              final String textToShow = snapshot.data == null ?'Arrived' :snapshot.data!;
                              return Text(
                                textToShow ,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'ReadexPro',
                                  fontWeight: FontWeight.w800,
                                ),
                              );
                            }
                          ),
                          const SizedBox(height: 30,),
                          const Text(
                            'DEPARTURE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Text(
                            departure,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'ReadexPro',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 25,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons horizontally
                            children: [
                              SizedBox(
                                height: 40,
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String result = await parkingLotService.cancelReservation(user.uid);
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result),
                                        duration: const Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: result.contains('successfully') ? Colors.green : Colors.red,
                                      )
                                    );
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => const HomePage())
                                    );
                                    // Handle what happens when cancel is pressed
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor:const Color(0xff114232),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                     // Button background color
                                    ),
                                  ),
                                  child: const Text('Cancel',
                                    style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ReadexPro',
                                    fontWeight: FontWeight.bold,
                                  fontSize: 15,),),
                                ),
                              ),
                              const SizedBox(width: 30,),
                              SizedBox(
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Edit'), // Title of the dialog box
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Enter expected time of ARRIVAL',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontFamily: 'ReadexPro',
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            if (arrival == '')
                                              const Center(
                                                child: Text(
                                                  'Arrived',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontFamily: 'ReadexPro',
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              )
                                            else
                                              TimeButton(
                                                buttonText: arrival,
                                                onTimePicked: (TimeOfDay time) {
                                                  arrival = time.format(context);
                                                },
                                              ),
                                            
                                            const SizedBox(height: 40),
                                            const Text(
                                              'Enter expected time of DEPARTURE',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontFamily: 'ReadexPro',
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Center(
                                              child: TimeButton(
                                                buttonText: departure,
                                                onTimePicked: (TimeOfDay time) {
                                                  departure = time.format(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
                                            String result = await parkingLotService.editArrivalDeparture(user.uid,arrival,departure
                                          );
        
                                          // ignore: use_build_context_synchronously
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result),
                                              duration: const Duration(seconds: 3),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Colors.green,
                                            )
                                            );
                                          // await Future.delayed(Duration(seconds: 3));
                                          if (result.contains('successfully')) {
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                            setState(() {
                                            });
                                         
                                        }
                                      },         
                                            child: const Text('Okay'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
        
                                },
                                
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xff114232),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ReadexPro',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
        
                            ],
                         
                        ),
                        const SizedBox(height: 20),
                        ],
                      ),
                    ),
          
                  ],
                  
                ),
              ),
            )
          );
        }else {
          return const HomePage();
        }
      }
    );
  
  }
}

