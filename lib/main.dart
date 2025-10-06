// main.dart
import 'package:bbqlagao_and_beefpares/pages/auth/hello_page.dart';
import 'package:bbqlagao_and_beefpares/pages/auth/login_page.dart';
import 'package:bbqlagao_and_beefpares/pages/auth/signup_page.dart';
import 'package:bbqlagao_and_beefpares/pages/auth/welcome_page.dart';
import 'package:bbqlagao_and_beefpares/pages/customer/cart_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/staff_home_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/cashier_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/users_controller.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:bbqlagao_and_beefpares/providers/cart_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _registerFirstAdmin();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/hello',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD84315), // Warm burnt orange
            primary: const Color(0xFFD84315), // Rich, appetizing orange-red
            secondary: const Color(0xFFFF8A65), // Lighter warm accent
            surface: const Color(0xFFFFF8F0), // Warm cream background
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFFFAF5), // Soft warm white

          textTheme: GoogleFonts.tiltNeonTextTheme().copyWith(
            headlineLarge: GoogleFonts.tiltNeon(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            headlineMedium: GoogleFonts.tiltNeon(fontWeight: FontWeight.w600),
            bodyLarge: GoogleFonts.tiltNeon(),
            bodyMedium: GoogleFonts.tiltNeon(), 
          ),


          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD84315),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              elevation: 2,
              shadowColor: const Color(0xFFD84315).withOpacity(0.3),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD84315),
              side: const BorderSide(color: Color(0xFFD84315), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),

          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.1),
            color: Colors.white,
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFD84315),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD84315), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          iconTheme: IconThemeData(color: Colors.deepOrangeAccent),
        ),
        routes: {
          '/welcome': (context) => WelcomePage(),
          '/hello': (context) => HelloPage(),
          '/signup': (context) => SignupPage(),
          '/login': (context) => LoginPage(),
          '/cart': (context) => CartPage(),
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
    await usersController.addUser(adminUser, 'password');
  }
}
