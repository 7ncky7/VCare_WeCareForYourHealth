import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/pages/application_page.dart';

class RedemptionPage extends StatefulWidget {
  const RedemptionPage({super.key});

  @override
  _RedemptionPageState createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  int _carePoints = 0; // Total care points retrieved from Firestore
  bool _isLoading = true; // Track loading state
  String? _userId; // Store the authenticated user's ID

  // Voucher data
  final List<Map<String, dynamic>> _vouchers = [
    {'image': '75voucher.png', 'points': 750, 'discount': '75%'},
    {'image': '50voucher.png', 'points': 500, 'discount': '50%'},
    {'image': '30voucher.png', 'points': 300, 'discount': '30%'},
    {'image': '10voucher.png', 'points': 100, 'discount': '10%'},
  ];

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadData();
  }

  // Get the authenticated user's ID and load their data
  Future<void> _getUserIdAndLoadData() async {
    try {
      // Get the current authenticated user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If no user is logged in, show an error and redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      setState(() {
        _userId = user.uid; // Set the user ID from Firebase Authentication
      });

      // Load user data from Firestore
      await _loadUserData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving user: $e')),
      );
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_userId == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _carePoints = userDoc['carePoints'] ?? 0;
          _isLoading = false;
        });
      } else {
        // If the user document doesn't exist, create it
        await FirebaseFirestore.instance.collection('users').doc(_userId).set({
          'carePoints': 0,
          'currentDay': 1,
          'lastCheckIn': null,
          'email': FirebaseAuth.instance.currentUser?.email,
        });
        setState(() {
          _carePoints = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  // Handle voucher redemption
  Future<void> _redeemVoucher(int pointsRequired, String discount) async {
    if (_userId == null) return;

    if (_carePoints >= pointsRequired) {
      // Sufficient care points, proceed with redemption
      int newCarePoints = _carePoints - pointsRequired;

      try {
        // Update Firestore with the new care points
        await FirebaseFirestore.instance.collection('users').doc(_userId).update({
          'carePoints': newCarePoints,
        });

        setState(() {
          _carePoints = newCarePoints;
        });

        // Show success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(
              'You have successfully redeemed the $discount gift voucher and the remaining care points have been updated.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error redeeming voucher: $e')),
        );
      }
    } else {
      // Insufficient care points
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Insufficient Care Points, the gift voucher redemption failed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
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
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, right: 15, bottom: 20, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Care Points and Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/carepoints_icon.png',
                              height: 130,
                              color: const Color(0xFF852745),
                            ),
                            Text(
                              '$_carePoints',
                              style: const TextStyle(
                                color:  Color(0xFF852745),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              localizations?.carePointsRedemption ?? 'Care Points Redemption',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: const Color(0xFF852745),
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // 2. Peach Box with Vouchers
                    Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20, bottom: 15, left: 20),
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: _vouchers.map((voucher) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Container(
                                      width: double.infinity,
                                      // padding: const EdgeInsets.all(15),
                                      padding: const EdgeInsets.only(top: 15, right: 15, bottom: 10, left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.8),
                                            spreadRadius: 3,
                                            blurRadius: 5,
                                          ),
                                        ],
                                        // border: Border.all(
                                        //   color: const Color.fromARGB(255, 119, 26, 26),
                                        //   width: 1.5,
                                        // ),
                                      ),
                                      child: Column(
                                        children: [
                                          // Voucher Image
                                          Image.asset(
                                            'assets/images/${voucher['image']}',
                                            height: 130,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(height: 10),

                                          // Row with Care Points and Redeem Button
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/carepoints_icon.png',
                                                    height: 30,
                                                    color: const Color(0xFF852745),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '${voucher['points']} Care Points',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Color(0xFF852745),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () => _redeemVoucher(
                                                  voucher['points'],
                                                  voucher['discount'],
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF852745),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: Text(
                                                  localizations?.redeem ?? 'Redeem',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}