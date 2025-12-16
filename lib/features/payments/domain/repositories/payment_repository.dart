import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<int> insertPayment(PaymentEntity payment);

  Future<List<PaymentEntity>> getPaymentsByStatus(String status);

  Future<void> updatePayment(PaymentEntity payment);
}
