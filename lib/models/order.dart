// models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String? id;
  final int orderId;
  final String? userId;
  final String name;
  final List<Map<String, dynamic>> items;
  final String status;
  final double totalAmount;
  final String orderType;
  final DateTime createdAt;
  final DateTime? preparedAt;
  final DateTime? servedAt;
  final DateTime updatedAt;

  Order({
    this.id,
    required this.orderId,
    this.userId,
    required this.name,
    required this.items,
    this.status = 'reviewing',
    required this.totalAmount,
    this.orderType = 'dine-in',
    required this.createdAt,
    this.preparedAt,
    this.servedAt,
    required this.updatedAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Order(
      id: doc.id,
      orderId: data['orderId'] ?? 0,
      userId: data['userId'],
      name: data['name'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      status: data['status'] ?? 'reviewing',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      orderType: data['orderType'] ?? 'dine-in',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preparedAt: (data['preparedAt'] as Timestamp?)?.toDate(),
      servedAt: (data['servedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      if (userId != null) 'userId': userId,
      'name': name,
      'items': items,
      'status': status,
      'totalAmount': totalAmount,
      'orderType': orderType,
      'createdAt': Timestamp.fromDate(createdAt),
      if (preparedAt != null) 'preparedAt': Timestamp.fromDate(preparedAt!),
      if (servedAt != null) 'servedAt': Timestamp.fromDate(servedAt!),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
