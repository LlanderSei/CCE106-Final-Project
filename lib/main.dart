import 'package:bbqlagao_and_beefpares/pages/manager/staff_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MaterialApp(
        initialRoute: '/staff',
        routes: {
          // '/auth': (context) => AuthScreen(),
          '/staff': (context) => StaffHomePage(),
        },
      ),
    ),
  );
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
      home: StaffHomePage(),
    );
  }
}
