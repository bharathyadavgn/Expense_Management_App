import '../../../../core/database/db_helper.dart';
import '../models/payment_model.dart';

class PaymentDao {
  final dbProvider = DBHelper.database;

  Future<int> insertPayment(PaymentModel payment) async {
    final db = await dbProvider;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<PaymentModel>> getPaymentsByStatus(String status) async {
    final db = await dbProvider;
    final maps = await db.query('payments',
        where: 'status = ?', whereArgs: [status], orderBy: 'date DESC');
    return maps.map((m) => PaymentModel.fromMap(m)).toList();
  }

  Future<void> updatePayment(PaymentModel payment) async {
    final db = await dbProvider;
    await db.update('payments', payment.toMap(),
        where: 'id = ?', whereArgs: [payment.id]);
  }
}
