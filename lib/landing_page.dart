import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Welcome to Mobile Fitness Tracker!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.0),
            // Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/browse');
              },
              child: Text('Button'),
            ),
            SizedBox(height: 20.0),
            
            
          ],
        ),
      ),
    );
  }
}