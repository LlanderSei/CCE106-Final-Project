import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        children: const [
          Card(
            child: ListTile(
              title: Text('Order #123 - Beef Pares'),
              subtitle: Text('Date: Oct 1, 2025 - Status: Delivered'),
              trailing: Text('150'),
            ),
          ),
        ],
      ),
    );
  }
}
