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
              if (docID == null) {
                //firestoreService.addNote(textController.text);
              } else {
                //firestoreService.updateNote(docID, textController.text);
              }

              textController.clear();

              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
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
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      'Arrival: $arrivalTime',
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
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      'Departure: ${departureTime.isNotEmpty ? departureTime : 'Departed'}',
                                      style: const TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Row(
                                    children: [
                                      if (arrivalTime.isNotEmpty)
                                        ElevatedButton(
                                          onPressed: () => firestoreService.removeArrival(docID),
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
                                      if (arrivalTime.isNotEmpty) const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => firestoreService.cancelReservation(docID),
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
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ],
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
