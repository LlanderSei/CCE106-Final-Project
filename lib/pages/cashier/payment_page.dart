// pages/cashier/payment_page.dart
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/payment_controller.dart';
import 'package:bbqlagao_and_beefpares/models/payment.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  final Order order;
  final double totalAmount;

  const PaymentPage({
    super.key,
    required this.order,
    required this.totalAmount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentController _paymentController = PaymentController();
  final OrderController _orderController = OrderController();
  final _formKey = GlobalKey<FormState>();
  String _paymentType = 'Cash';
  String _provider = 'GCash';
  final _nameCtrl = TextEditingController(text: 'Customer');
  final _userAmountCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  double _change = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _userAmountCtrl.text = widget.totalAmount.toStringAsFixed(2);
    _userAmountCtrl.addListener(_updateChange);
    _updateChange();
  }

  void _updateChange() {
    final userAmount = double.tryParse(_userAmountCtrl.text) ?? 0.0;
    setState(() {
      _change = (userAmount - widget.totalAmount).clamp(0.0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCash = _paymentType == 'Cash';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Type'),
              DropdownButtonFormField<String>(
                initialValue: _paymentType,
                items: ['Cash', 'E-Payment']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Total Amount: ₱${widget.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (isCash) ...[
                const Text('Name'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                const Text('User Amount'),
                TextFormField(
                  controller: _userAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(),
                  validator: (value) {
                    final amount = double.tryParse(value!);
                    if (amount == null) return 'Invalid amount';
                    if (amount < widget.totalAmount)
                      return 'Insufficient amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Change: ₱${_change.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ] else ...[
                const Text('Payment Provider'),
                DropdownButtonFormField<String>(
                  initialValue: _provider,
                  items: ['GCash']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) => setState(() => _provider = value!),
                ),
                const Text('Mobile Number'),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(),
                  validator: (value) =>
                      value!.isEmpty ? 'Mobile number is required' : null,
                ),
                const Text('Reference Number'),
                TextFormField(
                  controller: _refCtrl,
                  decoration: const InputDecoration(),
                  validator: (value) =>
                      value!.isEmpty ? 'Reference number is required' : null,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!_isProcessing)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Back'),
              ),
            const SizedBox(width: 8),
            if (!_isProcessing)
              GradientButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isProcessing = true;
                    });
                    final paymentDetails = isCash
                        ? {
                            'name': _nameCtrl.text,
                            'userAmount': double.parse(_userAmountCtrl.text),
                            'change': _change,
                            'totalAmount': widget.totalAmount,
                          }
                        : {
                            'provider': _provider,
                            'mobileNumber': _mobileCtrl.text,
                            'referenceNumber': _refCtrl.text,
                            'totalAmount': widget.totalAmount,
                          };
                    final payment = Payment(
                      orderId: widget.order.orderId,
                      paymentMethod: _paymentType,
                      paymentDetails: paymentDetails,
                    );
                    await _paymentController.addPayment(payment);
                    final userProvider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );
                    final user = userProvider.user;
                    String formattedName = widget.order.name; // default
                    if (user != null) {
                      if (user.role == 'Cashier') {
                        formattedName = '${user.name} (Cashier)';
                      } else if (user.role == 'Manager' ||
                          user.role == 'Admin') {
                        formattedName = '${user.name} (Manager/Admin)';
                      } else {
                        formattedName = user.name;
                      }
                    }
                    final updatedOrder = Order(
                      id: widget.order.id,
                      orderId: widget.order.orderId,
                      userId: widget.order.userId,
                      name: formattedName,
                      items: widget.order.items,
                      status: widget.order.status,
                      totalAmount: widget.order.totalAmount,
                      orderType: widget.order.orderType,
                      createdAt: widget.order.createdAt,
                      preparedAt: widget.order.preparedAt,
                      servedAt: widget.order.servedAt,
                      updatedAt: widget.order.updatedAt,
                    );
                    await _orderController.addOrder(updatedOrder);
                    if (mounted)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    setState(() {
                      _isProcessing = false;
                    });
                  }
                },
                child: Text(
                  'Confirm Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const GradientCircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userAmountCtrl.removeListener(_updateChange);
    _userAmountCtrl.dispose();
    _mobileCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }
}
