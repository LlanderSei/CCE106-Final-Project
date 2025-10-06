import 'checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart';
import '../../models/user.dart';

class CartDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>>? cartItems;
  final VoidCallback? onClearCart;
  final Function(int)? onRemoveItem;
  final Function(String, int)? onUpdateQuantity;

  const CartDetailsPage({
    super.key,
    this.cartItems,
    this.onClearCart,
    this.onRemoveItem,
    this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCartItems = cartItems ?? [];
    final total = effectiveCartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] ?? 0) * (item['quantity'] ?? 1),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (effectiveCartItems.isNotEmpty && onClearCart != null)
            TextButton(
              onPressed: onClearCart,
              child: const Text(
                'Clear Cart',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: effectiveCartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: effectiveCartItems.length,
                    itemBuilder: (context, index) {
                      final item = effectiveCartItems[index];
                      return _buildCartItem(context, item, index);
                    },
                  ),
          ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD84315).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 20,
                            color: const Color(0xFFD84315),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Queue Number: #${(effectiveCartItems.isNotEmpty) ? effectiveCartItems.length + 10 : 0}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD84315),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '₱${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD84315),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: effectiveCartItems.isEmpty
                            ? null
                            : () {
                                // Convert Map items to CartItem objects
                                final cartItems = effectiveCartItems
                                    .map(
                                      (item) => CartItem(
                                        id: item['id'] as String,
                                        name: item['name'] as String,
                                        price: (item['price'] as num)
                                            .toDouble(),
                                        quantity: item['quantity'] as int,
                                        imageUrl: item['imageUrl'] as String?,
                                        description:
                                            item['description'] as String?,
                                      ),
                                    )
                                    .toList();

                                final userProvider = Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                );
                                final userId = userProvider.user?.id ?? '';

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutPage(
                                      cartItems: cartItems,
                                      totalAmount: total,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84315),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item['image'] ?? 'assets/food1.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey,
                  child: const Center(child: Text('Image Failed')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unknown Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] ?? 'No description',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${(item['price'] ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD84315),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: onUpdateQuantity == null
                        ? null
                        : () {
                            if ((item['quantity'] ?? 1) > 1) {
                              onUpdateQuantity!(item['name'], -1);
                            } else if (onRemoveItem != null) {
                              onRemoveItem!(index);
                            }
                          },
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    color: const Color(0xFFD84315),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item['quantity'] ?? 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: onUpdateQuantity == null
                        ? null
                        : () => onUpdateQuantity!(item['name'], 1),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    color: const Color(0xFFD84315),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
