import 'package:flutter/material.dart';
import 'create_account.dart'; // Import CreateAccountScreen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform login action
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Google Sign-In logic removed
                // Show a message or handle this case
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google Sign-In is not available')),
                );
              },
              child: const Text('Login with Google'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                );
              },
              child: const Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }
}
