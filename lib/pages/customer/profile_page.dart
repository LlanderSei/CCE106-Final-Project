import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../models/user.dart';
import '../auth/login_page.dart';
import 'order_history_page.dart';
import 'cart_page.dart';
import 'tracking_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final userEmail = user?.email ?? 'guest@example.com';
    final userName = user?.name ?? 'Guest User';
    final userInitial = userName.isNotEmpty ? userName[0] : 'G';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile - Coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD84315), Color(0xFFFF8A65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD84315).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar with initial
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userInitial,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD84315),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // User name
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                // User email
                Text(
                  userEmail,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions Grid
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'My Cart',
                  color: const Color(0xFFD84315),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  context,
                  icon: Icons.local_shipping_outlined,
                  label: 'Track',
                  color: const Color(0xFFFF8A65),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackingPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Account Section
          _buildSectionHeader('Account'),
          const SizedBox(height: 12),

          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Account Details',
            subtitle: 'Manage your personal information',
            onTap: () {
              _showComingSoon(context, 'Account Details');
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.location_on_outlined,
            title: 'Delivery Address',
            subtitle: 'Manage your delivery locations',
            onTap: () {
              _showComingSoon(context, 'Delivery Address');
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage saved payment options',
            onTap: () {
              _showComingSoon(context, 'Payment Methods');
            },
          ),

          const SizedBox(height: 28),

          // Orders Section
          _buildSectionHeader('Orders'),
          const SizedBox(height: 12),

          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Order History',
            subtitle: 'View your past orders',
            badge: '3',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
            ),
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.favorite_outline,
            title: 'Favorites',
            subtitle: 'Your favorite dishes',
            onTap: () {
              _showComingSoon(context, 'Favorites');
            },
          ),

          const SizedBox(height: 28),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          const SizedBox(height: 12),

          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              _showComingSoon(context, 'Notifications');
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              _showComingSoon(context, 'Language Settings');
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App settings and preferences',
            onTap: () {
              _showComingSoon(context, 'Settings');
            },
          ),

          const SizedBox(height: 28),

          // Support Section
          _buildSectionHeader('Support'),
          const SizedBox(height: 12),

          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with your orders',
            onTap: () {
              _showComingSoon(context, 'Help & Support');
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.star_outline,
            title: 'Rate Us',
            subtitle: 'Share your feedback',
            onTap: () {
              _showRatingDialog(context);
            },
          ),

          const SizedBox(height: 8),

          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              _showAboutDialog(context);
            },
          ),

          const SizedBox(height: 28),

          // Sign Out Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade700, size: 24),
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Sign out from your account',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red.shade400,
              ),
              onTap: () => _showSignOutDialog(context),
            ),
          ),

          const SizedBox(height: 28),

          // App Version
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 32,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Text(
                  'Beef Pares & BBQ Lagao',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD84315),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD84315), size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD84315),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFD84315),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Are you sure you want to sign out from your account?',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Color(0xFFD84315),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beef Pares and BBQ Lagao',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD84315),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your favorite beef pares and BBQ, now just a tap away! Enjoy delicious meals delivered fresh to your doorstep.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '© 2025 Beef Pares and BBQ Lagao\nAll rights reserved',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD84315),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Column(
                children: [
                  Icon(Icons.star, color: Color(0xFFD84315), size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Rate Our App',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How would you rate your experience?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                        icon: Icon(
                          rating > index ? Icons.star : Icons.star_border,
                          color: const Color(0xFFD84315),
                          size: 36,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: rating > 0
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thanks for rating us $rating stars!',
                              ),
                              backgroundColor: const Color(0xFFD84315),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      // Clear the cart if the user is signed in
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId != null) {
        final cartController = CartController(userId);
        final FirebaseAuth auth = FirebaseAuth.instance;
        await cartController.clear();
        await auth.signOut();
      }

      // Sign out the user
      userProvider.clearUser(); // Clear the user data from provider

      // Navigate to login page
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
