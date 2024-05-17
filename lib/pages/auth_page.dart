import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking/pages/list_page.dart';
import 'package:parking/pages/info_page.dart';
import 'package:parking/pages/login_page.dart';
import 'package:parking/pages/home_page.dart';
import 'package:parking/services/firestore.dart';
import 'dart:async';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  static void logoutUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreServices _firestoreService = FirestoreServices();
  bool _isLoading = true;
  bool _hasReserve = false;
  String _userType = "";

  @override
  void initState() {
    super.initState();
    _startTokenCheckTimer();
    _checkUserAuthState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTokenCheckTimer() {
    _timer = Timer.periodic(const Duration(hours: 24), (timer) async {
      await _checkTokenExpiration();
    });
  }

  Future<void> _checkTokenExpiration() async {
    try {
      final idTokenResult = await _auth.currentUser?.getIdTokenResult();
      final expirationTime = idTokenResult?.expirationTime;

      if (expirationTime != null && expirationTime.isBefore(DateTime.now())) {
        _logoutUser();
      }
    } catch (e) {

      _logoutUser();
    }
  }

  Future<void> _checkUserAuthState() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _logoutUser() {
    FirebaseAuth.instance.signOut();
    // Ensure this function is called to update the state
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      bool hasReserve = await _firestoreService.fetchReservationStatus(uid);
      String userType = await _firestoreService.fetchUserType(uid);
      setState(() {
        _hasReserve = hasReserve;
        _userType = userType;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold();
    } else {
      if (_auth.currentUser != null) {
        if (_userType == 'admin') {
          return const ListPage();
        } else if (_hasReserve) {
          return const InfoPage();
        } else {
          return const HomePage();
        }
      } else {
        return LoginPage();
      }
    }
  }
}
