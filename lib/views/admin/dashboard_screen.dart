// lib/views/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/controllers/admin/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final user = authController;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Admin Dashboard!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Text(
            user != null
                ? 'Logged in as: ${user.email ?? 'Unknown'}'
                : 'No user logged in',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
