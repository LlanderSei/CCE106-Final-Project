import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../controllers/auth/auth_controller.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../customer/home_page.dart';
import '../manager/staff_home_page.dart';
import '../cashier/cashier_home_page.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  void _checkLoggedIn() async {
    if (_authController.isLoggedIn()) {
      final user = await _authController.getCurrentUser();
      if (user != null && mounted) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        _navigateBasedOnRole(user);
      }
    }
  }

  void _navigateBasedOnRole(User user) {
    Widget homeScreen;
    switch (user.role) {
      case 'Manager':
      case 'Admin':
        homeScreen = const StaffHomePage();
        break;
      case 'Cashier':
        homeScreen = const CashierHomePage();
        break;
      case 'Customer':
      default:
        homeScreen = const CustomerHomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Back button aligned to top left
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: IconButton(
              //     icon: const Icon(Icons.arrow_back),
              //     onPressed: () => Navigator.pop(context),
              //   ),
              // ),
              const Spacer(flex: 2),

              // Logo with some breathing room
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 24),

              // Welcoming text
              const Text(
                'Hello!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Welcome back, we\'re happy to see you',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Divider with OR
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 16),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerHomeScreen(),
                  ),
                ),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
