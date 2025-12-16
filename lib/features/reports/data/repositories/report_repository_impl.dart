import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_dao.dart';
import '../models/report_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDao _dao = ReportDao();

  @override
  Future<int> insertReport(ReportEntity report) async {
    final model = ReportModel(
      id: report.id,
      title: report.title,
      purpose: report.purpose,
      userId: report.userId,
      totalAmount: report.totalAmount,
      status: report.status,
      submissionDate: report.submissionDate,
    );
    return await _dao.insertReport(model);
  }

  @override
  Future<ReportEntity?> getReportById(int id) async {
    return await _dao.getReportById(id);
  }

  @override
  Future<List<ReportEntity>> getReportsByUser(int userId) async {
    return await _dao.getReportsByUser(userId);
  }

  @override
  Future<List<ReportEntity>> getReportsByStatus(String status) async {
    return await _dao.getReportsByStatus(status);
  }

  @override
  Future<void> updateReport(ReportEntity report) async {
    final model = ReportModel(
      id: report.id,
      title: report.title,
      purpose: report.purpose,
      userId: report.userId,
      totalAmount: report.totalAmount,
      status: report.status,
      submissionDate: report.submissionDate,
    );
    await _dao.updateReport(model);
  }
}
