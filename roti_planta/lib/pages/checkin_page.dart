import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/application_page.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  int _carePoints = 0;
  List<bool> _checkInStatus = [false, false, false, false, false, false, false];
  List<int> _pointsPerDay = [1, 3, 5, 8, 10, 20, 30];
  DateTime? _lastCheckInDate;
  bool _canCheckInToday = true;
  Duration _countdownDuration = Duration.zero;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchCarePoints();
    _fetchCheckInStatus();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Fetch care points from Firestore
  void _fetchCarePoints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc['carePoints'] != null) {
          setState(() {
            _carePoints = doc['carePoints'] as int;
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'carePoints': 0,
          }, SetOptions(merge: true));
          setState(() {
            _carePoints = 0;
          });
        }
      }
    } catch (e) {
      print('Error fetching care points: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load care points. Please try again.')),
      );
    }
  }

  // Fetch check-in status and last check-in date from Firestore
  void _fetchCheckInStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          // Fetch check-in status
          List<dynamic>? checkInData = doc['checkInStatus'];
          if (checkInData != null && checkInData.length == 7) {
            setState(() {
              _checkInStatus = checkInData.cast<bool>();
            });
          } else {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'checkInStatus': [false, false, false, false, false, false, false],
            }, SetOptions(merge: true));
            setState(() {
              _checkInStatus = [false, false, false, false, false, false, false];
            });
          }

          // Fetch last check-in date (for streak reset logic)
          String? lastCheckIn = doc['lastCheckInDate'];
          if (lastCheckIn != null) {
            _lastCheckInDate = DateTime.parse(lastCheckIn);
            DateTime now = DateTime.now();
            DateTime lastCheckInDay = DateTime(
                _lastCheckInDate!.year, _lastCheckInDate!.month, _lastCheckInDate!.day);
            DateTime todayDay = DateTime(now.year, now.month, now.day);

            // Reset check-in status if the streak is broken (missed a day)
            int daysDifference = todayDay.difference(lastCheckInDay).inDays;
            if (daysDifference > 1) {
              _resetCheckInStatus();
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching check-in status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load check-in status. Please try again.')),
      );
    }
  }

  // Start the countdown timer for 24 hours
  void _startCountdown() {
    _countdownDuration = Duration(hours: 24); // Changed from 15 seconds to 24 hours

    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownDuration.inSeconds > 0) {
          _countdownDuration = _countdownDuration - Duration(seconds: 1);
        } else {
          _countdownTimer?.cancel();
          _canCheckInToday = true;
          _countdownDuration = Duration.zero;

          // Check if all days were checked in (Day 7 completed)
          if (_checkInStatus.every((status) => status == true)) {
            _resetCheckInStatus(); // Reset to start from Day 1
          }
        }
      });
    });
  }

  // Format the countdown duration as HH:MM:SS
  String _formatCountdown(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds'; // Updated to show hours as well
  }

  // Reset check-in status to start from Day 1 (without resetting carePoints)
  void _resetCheckInStatus() async {
    try {
      setState(() {
        _checkInStatus = [false, false, false, false, false, false, false];
        _canCheckInToday = true;
        _lastCheckInDate = null;
        _countdownDuration = Duration.zero;
        _countdownTimer?.cancel();
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'checkInStatus': _checkInStatus,
          'lastCheckInDate': null,
        });
      }
    } catch (e) {
      print('Error resetting check-in status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset check-in status. Please try again.')),
      );
    }
  }

  // Handle check-in action
  void _handleCheckIn() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Find the first unchecked day
        int dayIndex = _checkInStatus.indexOf(false);
        if (dayIndex != -1) {
          // Update care points
          int pointsToAdd = _pointsPerDay[dayIndex];
          int newCarePoints = _carePoints + pointsToAdd;

          // Update check-in status
          DateTime now = DateTime.now();
          setState(() {
            _checkInStatus[dayIndex] = true;
            _carePoints = newCarePoints;
            _canCheckInToday = false;
            _lastCheckInDate = now;
          });

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'carePoints': newCarePoints,
            'checkInStatus': _checkInStatus,
            'lastCheckInDate': now.toIso8601String(),
          });

          // Start the 24-hour countdown timer
          _startCountdown();

          // Refresh carePoints from Firestore to ensure UI consistency
          _fetchCarePoints();
        }
      }
    } catch (e) {
      print('Error during check-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check in. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF852745)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ApplicationPage()),
            );
          },
        ),
        backgroundColor: const Color(0xFFD59FA6),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD59FA6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, right: 10, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/checkin_icon.png',
                      height: 125,
                      color: const Color(0xFF852745),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations?.checkIn ?? 'Check In',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: const Color(0xFF852745),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations?.checkInDescription ??
                                  'Check in every day to earn care points.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 7.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: const Color(0xFFFFE5D9),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, right: 15, bottom: 20, left: 15),
                    child: Column(
                      children: [
                        // White box with logo and care points
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 30, right: 15, bottom: 30, left: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/Logo.png',
                                height: 130,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$_carePoints Care Points',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF852745),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Row of check-in days
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (index) {
                            return Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      _checkInStatus[index]
                                          ? 'assets/images/checkinred_icon.png'
                                          : 'assets/images/checkingrey_icon.png',
                                      height: 50,
                                    ),
                                    Text(
                                      '+${_pointsPerDay[index]}',
                                      style: TextStyle(
                                        color: _checkInStatus[index]
                                            ? Color(0xFF852745)
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Day ${index + 1}',
                                  style: TextStyle(
                                    color: _checkInStatus[index]
                                        ? Color(0xFF852745)
                                        : Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: 30),
                        // Check-in button with countdown
                        ElevatedButton(
                          onPressed: _canCheckInToday ? _handleCheckIn : null,
                          child: Text(
                            _canCheckInToday
                                ? localizations?.checkInButton ?? 'Check In Today'
                                : _formatCountdown(_countdownDuration),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canCheckInToday
                                ? const Color(0xFF852745)
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _canCheckInToday ? const Color(0xFF852745) : const Color.fromARGB(255, 131, 94, 105),
                                width: 2, // Border width
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}