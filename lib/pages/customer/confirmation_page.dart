import 'package:flutter/material.dart';
import 'home_page.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const Text('Your order has been confirmed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomerHomeScreen())),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
