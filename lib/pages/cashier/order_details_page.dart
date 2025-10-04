//order_details_page.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/payment_controller.dart';
import 'package:bbqlagao_and_beefpares/models/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cfs;
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final OrderController _orderController = OrderController();
  final cfs.FirebaseFirestore _firestore = cfs.FirebaseFirestore.instance;
  final Map<String, String> _dishNames = {};
  bool _loading = false;
  bool _namesLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchDishNames();
  }

  Future<void> _fetchDishNames() async {
    final futures = widget.order.items.map((item) async {
      final dishId = item['dishId'] as String;
      final doc = await _firestore.collection('menu').doc(dishId).get();
      if (doc.exists) {
        _dishNames[dishId] = doc.data()!['name'] as String;
      }
    });
    await Future.wait(futures);
    setState(() {
      _namesLoaded = true;
    });
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _loading = true;
    });
    try {
      await _orderController.updateOrderStatus(widget.order.id!, status);
      Toast.show('Order status updated to $status');
      Navigator.pop(context);
    } catch (e) {
      Toast.show('Error updating status: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
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
            colors: GradientColorSets.set3,
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus('cancelled');
            },
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: GradientCircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text('Order Details'),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ordered By: ${widget.order.name}'),
                                  const Text('Order Type: Dine-in'),
                                  Text(
                                    'Order Created At: ${DateFormat('MMM dd, yyyy hh:mm a').format(widget.order.createdAt)}',
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Items:'),
                                  if (!_namesLoaded)
                                    const Center(
                                      child:
                                          GradientCircularProgressIndicator(),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: widget.order.items.length,
                                      itemBuilder: (context, index) {
                                        final item = widget.order.items[index];
                                        final dishId = item['dishId'] as String;
                                        final quantity =
                                            item['quantity'] as int;
                                        final name =
                                            _dishNames[dishId] ??
                                            'Unknown Dish';
                                        return ListTile(
                                          leading: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          trailing: Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text('Payment Details'),
                          initiallyExpanded: false,
                          children: [
                            StreamBuilder<List<Payment>>(
                              stream: PaymentController().getPaymentsByOrderId(
                                widget.order.orderId,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: GradientCircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text('No payments yet.');
                                }
                                final payments = snapshot.data!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: payments.length,
                                  itemBuilder: (context, index) {
                                    final payment = payments[index];
                                    return ListTile(
                                      title: Text(
                                        'Amount: ₱${payment.paymentDetails['totalAmount'] ?? 'N/A'}',
                                      ),
                                      subtitle: Text(
                                        'Method: ${payment.paymentMethod} \n${payment.paymentMethod == 'Cash' ? '' : 'Provider: ${payment.paymentDetails['provider']}\nMobile Number: ${payment.paymentDetails['mobileNumber']}\nReference Num: ${payment.paymentDetails['referenceNumber']}'}',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: _loading
            ? const Center(child: GradientCircularProgressIndicator())
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orangeAccent),
                      foregroundColor: Colors.orangeAccent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                  if (status == 'reviewing')
                    GradientButton(
                      onPressed: _cancelOrder,
                      colors: GradientColorSets.set1,
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (status == 'reviewing')
                    GradientButton(
                      onPressed: () => _updateStatus('preparing'),
                      child: const Text(
                        'To Prepare',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (status == 'preparing')
                    GradientButton(
                      onPressed: () => _updateStatus('serving'),
                      child: const Text(
                        'To Serve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (status == 'serving')
                    GradientButton(
                      onPressed: () => _updateStatus('completed'),
                      child: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
