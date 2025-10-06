import 'package:flutter/material.dart';
import 'hello_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.red[800]!, Colors.orange])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/logo.jpg', height: 150),
              const SizedBox(height: 100),
              Text("Let's get started",
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HelloPage())),
                child: const Text('Continue ->'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
