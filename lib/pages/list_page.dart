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

  void openActionDialog(String docID, String arrivalTime, String departureTime,String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (arrivalTime.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  String logID = await firestoreService.addLogArrival(arrivalTime,name);
                  firestoreService.removeArrival(docID);
                  Navigator.pop(context);
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
              onPressed: () {
                firestoreService.addLogDeparture( logID, departureTime);
                firestoreService.cancelReservation(docID);
                Navigator.pop(context);
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getUserStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> userList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      // Get each individual doc
                      DocumentSnapshot document = userList[index];
                      String docID = document.id;
                      // Get note from each doc
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      String name = data['name'] ?? 'No name';
                      String arrivalTime = data['arrival'] ?? '';
                      String departureTime = data['departure'] ?? '';

                      // Display as a list tile
                      return InkWell(
                        onTap: () => openActionDialog(docID, arrivalTime,departureTime,name),
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
                                            Text(
                                              arrivalTime.isNotEmpty ? arrivalTime : 'Arrived',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
    );
  }
}
