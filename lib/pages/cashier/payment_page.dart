// pages/cashier/payment_page.dart
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/payment_controller.dart';
import 'package:bbqlagao_and_beefpares/models/payment.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';

class PaymentPage extends StatefulWidget {
  final Order order;
  final double totalAmount;

  const PaymentPage({super.key, required this.order, required this.totalAmount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentController _paymentController = PaymentController();
  final _formKey = GlobalKey<FormState>();
  String _paymentType = 'Cash';
  String _provider = 'GCash';
  final _nameCtrl = TextEditingController(text: 'Customer');
  final _amountCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.totalAmount.toStringAsFixed(2);
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
                value: _paymentType,
                items: ['Cash', 'E-Payment'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (isCash) ...[
                const Text('Name'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                const Text('Amount'),
                TextFormField(
                  controller: _amountCtrl,
                  enabled: false,
                  decoration: const InputDecoration(),
                  validator: (value) => double.tryParse(value!) == null ? 'Invalid amount' : null,
                ),
              ] else ...[
                const Text('Payment Provider'),
                DropdownButtonFormField<String>(
                  value: _provider,
                  items: ['GCash'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (value) => setState(() => _provider = value!),
                ),
                const Text('Mobile Number'),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? 'Mobile number is required' : null,
                ),
                const Text('Reference Number'),
                TextFormField(
                  controller: _refCtrl,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? 'Reference number is required' : null,
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
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final paymentDetails = isCash
                      ? {'name': _nameCtrl.text, 'amount': double.parse(_amountCtrl.text)}
                      : {'provider': _provider, 'mobileNumber': _mobileCtrl.text, 'referenceNumber': _refCtrl.text};
                  final payment = Payment(
                    orderId: widget.order.orderId,
                    paymentMethod: _paymentType,
                    paymentDetails: paymentDetails,
                  );
                  await _paymentController.addPayment(payment);
                  if (mounted) Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              child: const Text('Add Order', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _mobileCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }
}