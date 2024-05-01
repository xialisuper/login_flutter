import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Placeholder(
              fallbackHeight: 200,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Go to Admin Page'),
            ),
          ],
        ),
      ),
    );
  }
}
