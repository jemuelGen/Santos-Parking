import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

//import 'package:firebase_auth/firebase_auth.dart';



class FirestoreServices {
  final CollectionReference slots = FirebaseFirestore.instance.collection('parkingLot');
  final CollectionReference userDetails = FirebaseFirestore.instance.collection('User');
  
  Stream<bool> departureTimeStream(String uid){
    return userDetails.doc(uid).snapshots().map((snapshot){
      if (!snapshot.exists) return false;
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['departure'] !=null;
    });
  }
  Stream<bool> arrivalTimeStream(String uid){
    return userDetails.doc(uid).snapshots().map((snapshot){
      if (!snapshot.exists) return false;
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['arrival'] !=null;
    });
  }
  

  //read all users who is reserve
  Stream<QuerySnapshot> getUserStream() {
  final userStream = userDetails.where('reserve', isEqualTo: true).snapshots();
  return userStream;
}

  //fetchUserType
  Future<String> fetchUserType(String uid) async {
    try {
      DocumentSnapshot userDocument = await userDetails.doc(uid).get();
      if (userDocument.exists) {
        Map<String, dynamic>? data = userDocument.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('userType')) {
          return data['userType'] as String;
        } else {
          return "No user type found";
        }
      } else {
        return "No user type found";
      }
    } catch (e) {
      return "Error fetching user type";
    }
  }
  //fetch reservation status
  Future<bool> fetchReservationStatus(String userId) async {
    try {
      // Get the user document from Firestore
      DocumentSnapshot snapshot = await userDetails.doc(userId).get();

      // Check if the document exists and contains the 'reserved' field
      if (snapshot.exists && snapshot.data() != null) {
        // Cast snapshot.data() to Map<String, dynamic> and access the 'reserved' field
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        // Return the value of the 'reserved' field
        return data['reserve'] as bool;
      } else {
        // If the document doesn't exist or the field is not found, return false
        return false;
      }
    } catch (e) {
      // Handle any errors and return false
      return false;
    }
  }
  //fetch arrival time
  Stream<String?> fetchArrivalTime(String userId) async* {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot document = await userDetails.doc(userId).get();

      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        // Check if 'arrival' field is available
        if (data != null && data.containsKey('arrival')) {
          yield data['arrival'];
        } else {
          yield null;
        }
      } else {
        yield 'User document does not exist';
      }
    } catch (e) {
      yield 'Error fetching arrival time';
    }
  }
  Future<String> fetchDepartureTime(String userId) async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot document = await userDetails.doc(userId).get();

      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        // Check if 'arrival' field is available
        if (data != null && data.containsKey('departure')) {
          return data['departure'];
        } else {
          return 'departure time not set';
        }
      } else {
        return 'User document does not exist';
      }
    } catch (e) {
      return 'Error fetching depature time';
    }
  }
  
  //fetch vacant parkinglots
  Stream<int> getSlots() {
    return slots.where('vacant', isEqualTo: true).snapshots().map((snapshot){
      return snapshot.docs.length;
    });
  }
  DateTime _parseTimeOfDay(String time) {
    final format = DateFormat.jm();
    return format.parse(time);
  }

  //reserve lots
  Future<String> reserveUsers(String uid, String arrival, String departure, bool vacant) async {
  try {
    DateTime arrivalDateTime = _parseTimeOfDay(arrival);
    DateTime departureDateTime = _parseTimeOfDay(departure);

    if (arrivalDateTime.isAfter(departureDateTime)) {
      return 'Arrival time cannot be later than departure time.';
    }

    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('User').doc(uid);

    // Query to find a parking lot that is vacant
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('parkingLot')
      .where('vacant', isEqualTo: true)
      .limit(1)
      .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot parkingLotDoc = querySnapshot.docs.first;
      final DocumentReference parkingLotRef = parkingLotDoc.reference;

      await userDocRef.update({
      'arrival': arrival, // assuming this and the next are already formatted appropriately
      'departure': departure, 
      'reserve': vacant,
    });
      // Update the parking lot to mark it as no longer vacant
      await parkingLotRef.update({'vacant': false});

      return 'Reservation successful, parking lot reserved';
    } else {
      return 'no vacant parking lot available';
    }
    } catch (e) {
      return 'Error reserving: ${e.toString()}';
    }
  }
  //delete arrival time
  Future<String> removeArrival(String uid) async {
  try {
    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('User').doc(uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists && userDoc.data() != null) {
      await userDocRef.update({
        'arrival': FieldValue.delete(),
      });
      return 'Reservation cancelled successfully';
    }
     else {
      return 'No reservation found to cancel';}
  }
  catch (e) {
    return 'Error cancelling reservation: ${e.toString()}';
  }
}
  //cancel reservation
  Future<String> cancelReservation(String uid) async {
  try {
    // Retrieve the user's reservation details
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('parkingLot')
      .where('vacant', isEqualTo: false)
      .limit(1).get();

    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('User').doc(uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists && userDoc.data() != null) {
      // Update the user document to remove reservation details or mark as not reserved
      await userDocRef.update({
        'arrival': FieldValue.delete(),
        'departure': FieldValue.delete(),
        'reserve': false,
      });
       DocumentSnapshot parkingLotDoc = querySnapshot.docs.first;
      DocumentReference parkingLotRef = parkingLotDoc.reference;
      await parkingLotRef.update({'vacant': true});

      return 'Reservation cancelled successfully';
    } else {
      return 'No reservation found to cancel';
    }
  } catch (e) {
    return 'Error cancelling reservation: ${e.toString()}';
  }
}

//cancel a parking lot
  Future<String> setAnyNonVacantParkingLotToVacant() async {
  try {
    // Query for the first non-vacant parking lot
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('parkingLot')
        .where('vacant', isEqualTo: false)
        .limit(1)  // Ensures only one parking lot is affected
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first non-vacant parking lot
      DocumentSnapshot parkingLotDoc = querySnapshot.docs.first;
      DocumentReference parkingLotRef = parkingLotDoc.reference;

      // Update the parking lot to vacant
      await parkingLotRef.update({'vacant': true});
      return 'Parking lot set to vacant successfully';
    } else {
      return 'No non-vacant parking lots found';
    }
  } catch (e) {
    return 'Error setting parking lot to vacant: ${e.toString()}';
  }
}

  //edit departure time
  Future<String> editArrivalDeparture(String uid, String arrival, String departure) async {
  try {
    DateTime? arrivalDateTime;
    if (arrival.isNotEmpty) {
      arrivalDateTime = _parseTimeOfDay(arrival);
    }

    DateTime departureDateTime = _parseTimeOfDay(departure);

    if (arrivalDateTime != null && arrivalDateTime.isAfter(departureDateTime)) {
      return 'Arrival time cannot be later than departure time.';
    }

    final DocumentReference userDocRef = FirebaseFirestore.instance.collection('User').doc(uid);

    Map<String, dynamic> updateData = {'departure': departure};

    if (arrival.isNotEmpty) {
      updateData['arrival'] = arrival;
    }

    await userDocRef.update(updateData);

    return 'Arrival and Departure time successfully updated';
  } catch (e) {
    return "Error reserving: ${e.toString()}";
  }
}

}
