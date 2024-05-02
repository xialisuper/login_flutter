import 'package:flutter/material.dart';
import 'package:login_flutter/util/local_data_storage.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  void _handleButtonTapped() {}

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
              onPressed: _handleButtonTapped,
              child: const Text('Go to Admin Page'),
            ),
          ],
        ),
      ),
    );
  }
}
