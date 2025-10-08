//orders_tab_page.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:flutter/rendering.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_details_page.dart';

class OrdersTabPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const OrdersTabPage({super.key, this.onFabVisibilityChanged});

  @override
  State<OrdersTabPage> createState() => _OrdersTabPageState();
}

class _OrdersTabPageState extends State<OrdersTabPage> {
  final ScrollController _scrollController = ScrollController();
  final OrderController _controller = OrderController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Show FAB when scrolling up, hide when scrolling down
    final isScrollingDown =
        _scrollController.position.userScrollDirection ==
        ScrollDirection.reverse;
    if (widget.onFabVisibilityChanged != null) {
      widget.onFabVisibilityChanged!(!isScrollingDown);
    }
  }

  Future<void> _updateStatus(Order order, String status) async {
    try {
      await _controller.updateOrderStatus(order.id!, status);
      Toast.show('Order updated to $status');
    } catch (e) {
      Toast.show('Error: $e');
    }
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orangeAccent),
              foregroundColor: Colors.orangeAccent,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          GradientButton(
            colors: GradientColorSets.set1,
            onPressed: () async {
              Navigator.pop(context);
              await _controller.updateOrderStatus(order.id!, 'cancelled', timestamp: DateTime.now());
            },
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Orders',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Order>>(
            stream: _controller.getOrdersByStatus('reviewing'),
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
                controller: _scrollController,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order #${order.orderId.toString()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(order.name),
                                Text('Dine-in'),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.cancel,
                                  offset: Offset.zero,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set1,
                                  ),
                                ),
                                onPressed: () => _cancelOrder(order),
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.kitchen,
                                  offset: Offset.zero,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set2,
                                  ),
                                ),
                                onPressed: () =>
                                    _updateStatus(order, 'preparing'),
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.visibility,
                                  offset: Offset.zero,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set3,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderDetailsPage(order: order),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
