import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_dao.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDao _dao = PaymentDao();

  @override
  Future<int> insertPayment(PaymentEntity payment) async {
    final model = PaymentModel(
      id: payment.id,
      reportId: payment.reportId,
      financeUserId: payment.financeUserId,
      transactionId: payment.transactionId,
      amount: payment.amount,
      date: payment.date,
      status: payment.status,
    );
    return await _dao.insertPayment(model);
  }

  @override
  Future<List<PaymentEntity>> getPaymentsByStatus(String status) async {
    return await _dao.getPaymentsByStatus(status);
  }

  @override
  Future<void> updatePayment(PaymentEntity payment) async {
    final model = PaymentModel(
      id: payment.id,
      reportId: payment.reportId,
      financeUserId: payment.financeUserId,
      transactionId: payment.transactionId,
      amount: payment.amount,
      date: payment.date,
      status: payment.status,
    );
    await _dao.updatePayment(model);
  }
}
