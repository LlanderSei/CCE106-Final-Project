// lib/views/admin/admin_home_screen.dart
import 'package:bbqlagao_and_beefpares/views/admin/admin_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/views/admin/dish_management_screen.dart';
import 'package:bbqlagao_and_beefpares/views/admin/inventory_screen.dart';
import 'package:bbqlagao_and_beefpares/controllers/admin/auth_controller.dart';
import 'package:bbqlagao_and_beefpares/views/admin/dashboard_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  late final authController = ref.watch(authControllerProvider);
  late final user = authController;
  String? _selectedTab;
  bool _isSidebarVisible = true;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 94, 94),
        title: Text(
          'Admin Dashboard${_selectedTab != null ? ': $_selectedTab' : ''}',
        ),
        actions: [
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
            onPressed: () {
              setState(() {
                _isSidebarVisible = !_isSidebarVisible;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isSidebarVisible ? 175 : 0,
            color: Colors.grey[200],
            child: _isSidebarVisible
                ? Column(
                    children: [
                      // Start modification: Added Home group at the top
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          user != null
                              ? 'Currently logged in as: ${user?.email ?? 'Unknown'}'
                              : 'No user logged in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          'Home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey[400], height: 1.0),
                      Container(
                        color: _selectedIndex == 0
                            ? Colors.grey[500]
                            : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            'Dashboard',
                            style: TextStyle(
                              color: _selectedIndex == 0 ? Colors.white : null,
                            ),
                          ),
                          selected: _selectedIndex == 0,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                              _selectedTab = null;
                            });
                          },
                        ),
                      ),
                      // End modification
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          'Inventory',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey[400], height: 1.0),
                      Container(
                        color: _selectedIndex == 1
                            ? Colors.grey[500]
                            : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            'Dishes',
                            style: TextStyle(
                              color: _selectedIndex == 1 ? Colors.white : null,
                            ),
                          ),
                          selected: _selectedIndex == 1,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                              _selectedTab = 'Dishes';
                            });
                          },
                        ),
                      ),
                      Container(
                        color: _selectedIndex == 2
                            ? Colors.grey[500]
                            : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            'Ingredients',
                            style: TextStyle(
                              color: _selectedIndex == 2 ? Colors.white : null,
                            ),
                          ),
                          selected: _selectedIndex == 2,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                              _selectedTab = 'Ingredients';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          'User Management',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey[400], height: 1.0),
                      Container(
                        color: _selectedIndex == 3
                            ? Colors.grey[500]
                            : Colors.transparent,
                        child: ListTile(
                          title: Text(
                            'Admins',
                            style: TextStyle(
                              color: _selectedIndex == 3 ? Colors.white : null,
                            ),
                          ),
                          selected: _selectedIndex == 3,
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                              _selectedTab = 'Admins';
                            });
                          },
                        ),
                      ),
                      // Start modification: Added Logout button at the bottom
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.grey[500],
                            child: ListTile(
                              leading: Icon(Icons.logout, color: Colors.white),
                              title: Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                final authController = ref.read(
                                  authControllerProvider.notifier,
                                );
                                await authController.logout();
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/auth',
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // End modification
                    ],
                  )
                : SizedBox(),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(), // New Dashboard screen
                DishManagementScreen(),
                InventoryScreen(),
                AdminManagementScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
