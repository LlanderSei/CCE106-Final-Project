// pages\manager\staff_home_page.dart
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/inventory_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/menu_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/staff_list_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_item_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_dish_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_user_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  String _currentPage = 'menu';
  String _appBarTitle = 'Staff Dashboard';
  String _tooltip = 'Add Menu';
  late ValueNotifier<bool> _showFabNotifier;
  bool _isManagementExpanded = true;
  bool _isUserManagementExpanded = true;

  void _onFabVisibilityChanged(bool visible) {
    _showFabNotifier.value = visible;
  }

  @override
  void initState() {
    super.initState();
    _showFabNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _showFabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_appBarTitle != 'Staff Dashboard')
              Text(
                'Staff Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            Text(_appBarTitle, style: TextStyle(color: Colors.white)),
          ],
        ),

        flexibleSpace:
            _currentPage == 'inventory' ||
                _currentPage == 'menu' ||
                _currentPage == 'staffs'
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
                  ),
                ),
              )
            : null,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 75.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'BBQ Lagao & Beef Pares',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      'Staff Navigation',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ExpansionTile(
                    initiallyExpanded: _isManagementExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isManagementExpanded = expanded;
                      });
                    },
                    title: const Text(
                      'Inventory Management',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    leading: const Icon(
                      Icons.business,
                      color: Colors.redAccent,
                    ),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.restaurant_menu,
                          color: _currentPage == 'menu'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Menu',
                          style: TextStyle(
                            color: _currentPage == 'menu'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'menu',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: 0.75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'menu';
                            _appBarTitle = 'Menu';
                            _tooltip = 'Add Menu';
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.inventory,
                          color: _currentPage == 'inventory'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Inventory',
                          style: TextStyle(
                            color: _currentPage == 'inventory'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'inventory',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'inventory';
                            _appBarTitle = 'Inventory';
                            _tooltip = 'Add Item';
                          });
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    initiallyExpanded: _isUserManagementExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isUserManagementExpanded = expanded;
                      });
                    },
                    title: const Text(
                      'User Management',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    leading: const Icon(Icons.people, color: Colors.redAccent),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.person,
                          color: _currentPage == 'staffs'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Staffs',
                          style: TextStyle(
                            color: _currentPage == 'staffs'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'staffs',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'staffs';
                            _appBarTitle = 'Staffs';
                            _tooltip = 'Add Staff';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close menu',
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton:
          (_currentPage == 'inventory' ||
              _currentPage == 'menu' ||
              _currentPage == 'staffs')
          ? ValueListenableBuilder<bool>(
              valueListenable: _showFabNotifier,
              builder: (context, showFab, child) {
                if (!showFab) return const SizedBox.shrink();
                return FloatingActionButton(
                  backgroundColor: Colors.redAccent[100],
                  shape: const CircleBorder(),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    if (_currentPage == 'inventory') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModifyItemPage(),
                        ),
                      );
                    } else if (_currentPage == 'menu') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModifyDishPage(),
                        ),
                      );
                    } else if (_currentPage == 'staffs') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModifyUserPage(),
                        ),
                      );
                    }
                  },
                  tooltip: _tooltip,
                  child: const Icon(Icons.add),
                );
              },
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case 'menu':
        return MenuPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'inventory':
        return InventoryPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'staffs':
        return StaffListPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      default:
        return const Center(child: Text('Page not implemented'));
    }
  }
}
