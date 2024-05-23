import 'package:flutter/material.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                hintText: 'Username',
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Confirm Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform create account action
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
