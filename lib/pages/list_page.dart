import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parking/services/firestore.dart';
import 'package:parking/pages/auth_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPage();
}

class _ListPage extends State<ListPage> {
  final FirestoreServices firestoreService = FirestoreServices();
  final TextEditingController textController = TextEditingController();
  String logID = '';

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void openActionDialog(String docID, String arrivalTime, String departureTime, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (arrivalTime.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  try {
                    logID = await firestoreService.addLogArrival(arrivalTime, name);
                    await firestoreService.removeArrival(docID);
                  } catch (e) {
                    print('Error: $e');
                  } finally {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff114232),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Arrived',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ReadexPro',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            if (arrivalTime.isNotEmpty) const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                try {
                  await firestoreService.addLogDeparture(logID, departureTime);
                  await firestoreService.cancelReservation(docID);
                } catch (e) {
                  print('Error: $e');
                } finally {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff114232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Departed',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ReadexPro',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'All Logs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getAllLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      List<DocumentSnapshot> logsList = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: logsList.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = logsList[index];
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          String name = data['name'] ?? 'No name';
                          String arrivalTime = data['arrival'] ?? '';
                          String departureTime = data['departure'] ?? '';
                          Timestamp timestamp = data['timestamp'] as Timestamp? ?? Timestamp.now();
                          
                          DateTime date = timestamp.toDate();
                          String formattedDate = '${date.day}/${date.month}/${date.year}';

                          return ListTile(
                            title: Text(name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Arrival: $arrivalTime'),
                                Text('Departure: $departureTime'),
                                Text('Date: $formattedDate'),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("No logs available."),
                      );
                    }
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await firestoreService.clearAllLogs();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff114232),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Clear All Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ReadexPro',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () {
            AuthPage.logoutUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthPage()),
            );
          },
          icon: const Icon(Icons.logout),
        )
      ]),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'SANTOS PARKING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StreamBuilder<int>(
            stream: firestoreService.getSlots(),
            builder: (BuildContext context,AsyncSnapshot<int> snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
              else if(snapshot.hasError){
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
                  '0',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontFamily: 'ReadexPro',
                    fontWeight: FontWeight.w400,
                  )
                );
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Available vacancies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
             ),
          const SizedBox(height: 10,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  List<DocumentSnapshot> userList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = userList[index];
                      String docID = document.id;
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String name = data['name'] ?? 'No name';
                      String arrivalTime = data['arrival'] ?? '';
                      String departureTime = data['departure'] ?? '';

                      return InkWell(
                        onTap: () => openActionDialog(docID, arrivalTime, departureTime, name),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey[400],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        width: 130,
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Arrival: ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              color: arrivalTime.isEmpty ? Colors.green : null,
                                              child: Text(
                                                arrivalTime.isNotEmpty ? arrivalTime : 'Arrived',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black, // Text color, added for visibility
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    width: 1,
                                    color: Colors.grey[400],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        width: 150,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Departure: ',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            Text(
                                              departureTime,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No reserved users yet..."),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 50.0, bottom:16.0),
          child: FloatingActionButton(
            onPressed: openLogsDialog,
            backgroundColor: const Color(0xff114232),
            child: const Icon(
              Icons.history,
              color: Colors.white,),
          ),
        ),
      ),
    );
  }
}
