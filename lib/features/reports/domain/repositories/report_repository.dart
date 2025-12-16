import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<int> insertReport(ReportEntity report);

  Future<void> updateReport(ReportEntity report);

  Future<ReportEntity?> getReportById(int id);

  Future<List<ReportEntity>> getReportsByUser(int userId);

  Future<List<ReportEntity>> getReportsByStatus(String status);
}
