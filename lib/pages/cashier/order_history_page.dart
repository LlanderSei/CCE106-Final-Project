// pages/cashier/order_history_page.dart
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_details_page.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:intl/intl.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final OrderController _controller = OrderController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Completed Orders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text('Actions', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: _controller.getOrdersByStatus('completed'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No completed orders found.'),
                  );
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
                                  Text(
                                    'Completed: ${DateFormat('MMM dd, yyyy hh:mm a').format(order.createdAt)}',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: GradientIcon(
                                icon: Icons.visibility,
                                offset: Offset.zero,
                                gradient: LinearGradient(
                                  colors: GradientColorSets.set1,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
