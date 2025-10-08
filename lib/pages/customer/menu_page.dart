// ignore_for_file: prefer_collection_literals

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/customer/menu_controller.dart' as menu_ctrl;
import '../../models/dish.dart';
import '../../models/user.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../providers/cart_provider.dart';
import 'menu_item_detail_page.dart';
import 'cart_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onCartPressed;
  const MenuPage({super.key, this.onCartPressed});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _selectedCategory = 'All';
  CartController? _cartController;
  final ScrollController _categoryScrollController = ScrollController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _initializeCart();
    menu_ctrl.MenuController.instance.getAllCategories().listen((categories) {
      setState(() {
        _categories = ['All', ...categories, 'Misc.'].toSet().toList();
      });
    });
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _cartController?.removeListener(_onCartChanged);
    super.dispose();
  }

  void _initializeCart() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _cartController = userProvider.cartController;
    if (_cartController != null) {
      _cartController!.addListener(_onCartChanged);
    }
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        automaticallyImplyLeading: false, // Remove leading back button
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed:
                    widget.onCartPressed ??
                    () => Navigator.pushNamed(context, '/cart'),
              ),
              if ((_cartController?.totalQuantity ?? 0) > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartController?.totalQuantity ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFFD84315),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filters
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    key: const PageStorageKey('category_scroll'),
                    controller: _categoryScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: _categories
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildCategoryChip(category),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),

          // Menu items grid
          Expanded(
            child: StreamBuilder<List<Dish>>(
              stream: _selectedCategory == 'All'
                  ? menu_ctrl.MenuController.instance.getAllDishes()
                  : menu_ctrl.MenuController.instance.getDishesByCategory(
                      _selectedCategory,
                    ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final dishes = snapshot.data ?? [];

                if (dishes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .65,
                  ),
                  padding: const EdgeInsets.all(16),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    if (!dish.isAvailable || !dish.isVisible)
                      return const SizedBox.shrink();
                    return _buildMenuItem(
                      context,
                      dish: dish,
                      name: dish.name,
                      description:
                          dish.description ?? 'No description available',
                      price: dish.price,
                      image:
                          dish.imageUrl ??
                          'lib/assets/food1.jpg', // Use default image if none provided
                      isPopular: false, // We'll implement this later
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

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD84315) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD84315) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD84315).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required Dish dish,
    required String name,
    required String description,
    required double price,
    required String image,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MenuItemDetailPage(itemName: name, price: price, image: image),
        ),
      ),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: image.isNotEmpty
                          ? (image.startsWith('http')
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.restaurant,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                  )
                                : Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.restaurant,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                  ))
                          : const Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  if (isPopular)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD84315),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Popular',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Details section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD84315),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_cartController != null) {
                                // Capture context before async
                                final cartProvider = Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                );
                                final messenger = ScaffoldMessenger.of(context);
                                await _cartController!.addItem(
                                  dish.id ?? dish.name,
                                  dish.name,
                                  dish.description,
                                  dish.price,
                                  dish.imageUrl,
                                );
                                // Update CartProvider for badge
                                cartProvider.addToCart(dish);
                                // Force rebuild to update icon immediately
                                setState(() {});
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('$name added to cart!'),
                                    backgroundColor: const Color(0xFFD84315),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                    action: SnackBarAction(
                                      label: 'VIEW',
                                      textColor: Colors.white,
                                      onPressed:
                                          widget.onCartPressed ??
                                          () => Navigator.pushNamed(
                                            context,
                                            '/cart',
                                          ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD84315),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _cartController?.items.any(
                                          (item) =>
                                              item.id == (dish.id ?? dish.name),
                                        ) ??
                                        false
                                    ? Icons.check
                                    : Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
