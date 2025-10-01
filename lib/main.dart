import 'package:bbqlagao_and_beefpares/views/admin/admin_home_screen.dart';
import 'package:bbqlagao_and_beefpares/views/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MaterialApp(
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => AuthScreen(),
          '/admin': (context) => AdminHomeScreen(),
        },
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required AdminHomeScreen home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Home Screen',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 161, 161),
        ),
      ),
      home: AdminHomeScreen(),
    );
  }
}
