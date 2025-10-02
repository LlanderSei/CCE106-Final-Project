// controllers/payment_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbqlagao_and_beefpares/models/payment.dart';

class PaymentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'payments';

  Future<void> addPayment(Payment payment) async {
    await _firestore.collection(_collection).add(payment.toFirestore());
  }

  Stream<List<Payment>> getPaymentsByOrderId(int orderId) => _firestore
      .collection(_collection)
      .where('orderId', isEqualTo: orderId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
      );
}
