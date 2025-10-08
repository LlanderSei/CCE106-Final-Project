import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/auth/auth_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final AuthController _authController = AuthController();
  final OrderController _orderController = OrderController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authController.getCurrentUser();
    if (user != null) {
      setState(() {
        _userId = user.id;
      });
    }
  }

  String _getTimestampText(Order order) {
    switch (order.status) {
      case 'completed':
        return 'Completed At: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.createdAt)}';
      case 'cancelled':
        return order.cancelledAt != null
            ? 'Cancelled At: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.cancelledAt!)}'
            : 'Cancelled At: N/A';
      case 'serving':
        return order.servedAt != null
            ? 'Served At: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.servedAt!)}'
            : 'Served At: N/A';
      case 'preparing':
        return order.preparedAt != null
            ? 'Prepared At: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.preparedAt!)}'
            : 'Prepared At: N/A';
      default:
        return 'Order At: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.createdAt)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: GradientCircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CustomerHomeScreen(initialSelectedIndex: 2),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<List<Order>>(
          stream: _orderController.getOrdersByUser(_userId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: GradientCircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders found.'));
            }
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final itemsText = order.items
                    .map((item) => '${item['name']} x${item['quantity']}')
                    .join(', ');
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text('Items: $itemsText'),
                        Text(
                          'Amount: ₱${order.totalAmount.toStringAsFixed(2)}',
                        ),
                        Text('Status: ${order.status}'),
                        Text(_getTimestampText(order)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
