// lib/views/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/controllers/admin/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Customer Auth Page (Design Only)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: null, // Design only, no function
                        child: Text('Register'),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: null, // Design only, no function
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ),
                // Admin Auth Page (Functional)
                Consumer(
                  builder: (context, ref, child) {
                    final authController = ref.watch(
                      authControllerProvider.notifier,
                    );
                    final emailController = TextEditingController();
                    final passwordController = TextEditingController();

                    return Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16.0),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(labelText: 'Password'),
                            obscureText: true,
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await authController.login(
                                  emailController.text,
                                  passwordController.text,
                                );
                                // Navigate to AdminHomeScreen on success
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/admin',
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Login failed: $e')),
                                );
                              }
                            },
                            child: Text('Login'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Sticky Tab Bar at the Bottom
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize
                  .tab, // Ensures indicator spans full tab width
              indicator: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  255,
                  81,
                  81,
                ), // Highlighted tab background
              ),
              tabs: [
                Tab(text: 'Customer'),
                Tab(text: 'Admin'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
