import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/order.dart' as order_model;
import '../../models/payment.dart' as payment_model;
import '../../models/dish.dart';
import '../../models/user.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../controllers/general/order_controller.dart';
import '../../controllers/general/payment_controller.dart';
import 'confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String userId;

  const CheckoutPage({
    required this.cartItems,
    required this.totalAmount,
    required this.userId,
    super.key,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const double SERVICE_FEE = 10.0;

  String _selectedOrderType = 'dine-in';
  String _selectedPayment = 'cash';
  final _gcashMobileController = TextEditingController();
  final _gcashReferenceController = TextEditingController();

  bool _isProcessing = false; // New loading state

  @override
  void dispose() {
    _gcashMobileController.dispose();
    _gcashReferenceController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_isProcessing) return; // Prevent multiple presses
    setState(() {
      _isProcessing = true;
    });

    if (_selectedPayment == 'gcash') {
      if (_gcashMobileController.text.isEmpty ||
          _gcashReferenceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in your GCash details'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      _showGCashQRDialog();
    } else {
      // For cash payment, no amount input required, just proceed
      _proceedToConfirmation();
    }
  }

  void _showGCashQRDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      // GCash QR Code Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'lib/assets/QR.jpg', // Add your QR code image here
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'QR Code',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFFD84315),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Scan this QR code using your GCash app',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '₱${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD84315),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _proceedToConfirmation();
                    },
                    child: const Text('I have paid'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final OrderController _orderController = OrderController();
  final PaymentController _paymentController = PaymentController();

  void _proceedToConfirmation() async {
    // Create order and payment records in Firestore
    final authController = AuthController();
    final user = await authController.getCurrentUser();
    final userName = user?.name ?? 'Customer';

    final orderId = await _orderController.getNextOrderId();

    final order = order_model.Order(
      orderId: orderId,
      userId: widget.userId,
      name: userName,
      items: widget.cartItems
          .map(
            (item) => <String, dynamic>{
              'dishId': item.id,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
            },
          )
          .toList(),
      totalAmount: widget.totalAmount,
      orderType: _selectedOrderType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _orderController.addOrder(order);

    final paymentDetails = _selectedPayment == 'gcash'
        ? <String, dynamic>{
            'mobileNumber': _gcashMobileController.text,
            'referenceNumber': _gcashReferenceController.text,
            'provider': 'GCash',
            'totalAmount': widget.totalAmount,
            'paymentMethod': 'E-Payment',
          }
        : <String, dynamic>{
            'change': null,
            'name': userName,
            'totalAmount': widget.totalAmount,
            'userAmount': null,
            'paymentMethod': 'Cash',
          };

    final payment = payment_model.Payment(
      orderId: orderId,
      paymentMethod: _selectedPayment == 'gcash' ? 'E-Payment' : 'Cash',
      paymentDetails: paymentDetails,
    );

    await _paymentController.addPayment(payment);

    // Clear cart after order placement
    final cartController = CartController(widget.userId);
    await cartController.clear();

    // Notify cart badge and items update by clearing CartProvider if used
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.cartController?.clear();

    setState(() {
      _isProcessing = false;
    });

    // Navigate to ConfirmationPage and remove checkout page from stack to avoid back button
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Type Dropdown
                  const Text(
                    'Order Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedOrderType,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'dine-in',
                          child: Text('Dine-in'),
                        ),
                        DropdownMenuItem(
                          value: 'take-out',
                          child: Text('Take-out'),
                        ),
                        DropdownMenuItem(
                          value: 'reservation',
                          child: Text('Reservation'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOrderType = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD84315).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD84315),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Queue #12',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Subtotal',
                          '₱${(widget.totalAmount - SERVICE_FEE).toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Service Fee',
                          '₱${SERVICE_FEE.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD84315),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Section
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // Payment upon arrival Option
                  _buildPaymentOption(
                    value: 'cash',
                    icon: Icons.money,
                    title: 'Payment upon arrival',
                    subtitle: 'Pay when you receive',
                  ),

                  const SizedBox(height: 12),

                  // GCash Option
                  _buildPaymentOption(
                    value: 'gcash',
                    icon: Icons.account_balance_wallet,
                    title: 'GCash',
                    subtitle: 'Pay via GCash QR',
                  ),

                  // GCash Details (shown only when GCash is selected)
                  if (_selectedPayment == 'gcash') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'GCash Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _gcashMobileController,
                      decoration: const InputDecoration(
                        labelText: 'GCash Mobile Number',
                        hintText: '09XX XXX XXXX',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _gcashReferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference Number',
                        hintText: 'Enter reference number',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // GCash QR Code Placeholder
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'QR Code Placeholder',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFFD84315),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Scan this QR code using your GCash app',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD84315),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _processPayment,
                          child: Text(
                            _selectedPayment == 'gcash'
                                ? 'Pay with GCash'
                                : 'Place Order',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPayment == value;

    return InkWell(
      onTap: () => setState(() => _selectedPayment = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD84315) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD84315).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFD84315)
                    : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFD84315)
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD84315),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
