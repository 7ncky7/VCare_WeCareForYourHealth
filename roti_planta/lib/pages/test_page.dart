import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          const Text('You are on the test page!'),
          SizedBox(height: 40),
          Text(location),
        ],
      ),
    );
  }
}
