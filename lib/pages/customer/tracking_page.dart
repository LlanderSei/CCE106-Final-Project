import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:bbqlagao_and_beefpares/controllers/auth/auth_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'home_page.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
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

  List<TimelineTile> _buildTimeline(Order order) {
    List<TimelineTile> tiles = [];

    // Order received
    tiles.add(
      TimelineTile(
        isFirst: true,
        indicatorStyle: const IndicatorStyle(color: Colors.green),
        endChild: const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Order received!'),
        ),
      ),
    );

    if (['reviewing', 'preparing', 'serving'].contains(order.status)) {
      tiles.add(
        TimelineTile(
          indicatorStyle: IndicatorStyle(
            color: order.status == 'reviewing' ? Colors.orange : Colors.green,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              order.status == 'reviewing'
                  ? 'Your order and payment is currently being reviewed.'
                  : 'Your order has been confirmed.',
            ),
          ),
        ),
      );
    }

    if (['preparing', 'serving'].contains(order.status)) {
      tiles.add(
        TimelineTile(
          indicatorStyle: IndicatorStyle(
            color: order.status == 'preparing' ? Colors.orange : Colors.green,
          ),
          endChild: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              order.status == 'preparing'
                  ? 'Your order is currently being prepared.'
                  : 'Your food have finished preparing.',
            ),
          ),
        ),
      );
    }

    if (order.status == 'serving') {
      tiles.add(
        TimelineTile(
          isLast: true,
          indicatorStyle: const IndicatorStyle(color: Colors.green),
          endChild: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Your food is ready to serve!'),
          ),
        ),
      );
    } else {
      // If not serving, make the last one last
      if (tiles.isNotEmpty) {
        tiles.last = TimelineTile(
          isLast: true,
          indicatorStyle: tiles.last.indicatorStyle,
          endChild: tiles.last.endChild,
        );
      }
    }

    return tiles;
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
          title: const Text('Tracking'),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<List<Order>>(
          stream: _orderController.getOngoingOrdersByUser(_userId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: GradientCircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No ongoing orders found.'));
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
                        const SizedBox(height: 16),
                        ..._buildTimeline(order),
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
