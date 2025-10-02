// main.dart
import 'package:bbqlagao_and_beefpares/pages/manager/staff_home_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/cashier_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/users_controller.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _registerFirstAdmin();
  runApp(
    ProviderScope(
      child: MaterialApp(
        initialRoute: '/cashier',
        routes: {
          // '/auth': (context) => AuthScreen(),
          '/staff': (context) => StaffHomePage(),
          '/cashier': (context) => CashierHomePage(),
        },
      ),
    ),
  );
}

Future<void> _registerFirstAdmin() async {
  final usersController = UsersController();
  final adminEmail = 'admin@admin.com';
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: adminEmail)
      .get();
  if (query.docs.isEmpty) {
    final adminUser = User(name: 'Admin', email: adminEmail, role: 'Admin');
    await usersController.addUser(null, adminUser, 'password');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manager Home Screen',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
    );
  }
}
