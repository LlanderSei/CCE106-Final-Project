import 'package:flutter/material.dart';

class MenuItemDetailPage extends StatelessWidget {
  final String itemName;
  final double price;
  final String image;
  final String? description;

  const MenuItemDetailPage({
    super.key,
    required this.itemName,
    required this.price,
    required this.image,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          itemName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                    BuildContext context,
                    Object exception,
                    StackTrace? stackTrace,
                  ) {
                    return const Icon(Icons.broken_image, size: 200);
                  },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Description: ${description ?? "No description provided."}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text('Customizations:', textAlign: TextAlign.center),
                  // Placeholder for customization options
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add to Cart'),
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
