// models/payment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String? id;
  final int orderId;
  final String paymentMethod;
  final Map<String, dynamic> paymentDetails;

  Payment({
    this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentDetails,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Payment(
      id: doc.id,
      orderId: data['orderId'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? '',
      paymentDetails: Map<String, dynamic>.from(data['paymentDetails'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
    };
  }
}
