import 'package:flutter/material.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/employee_dashboard.dart';
import '../features/auth/presentation/manager_dashboard.dart';
import '../features/auth/presentation/finance_dashboard.dart';
import '../features/expenses/presentation/create_expense_page.dart';
import '../features/expenses/presentation/expense_details_page.dart';
import '../features/expenses/presentation/expense_list_page.dart';
import '../features/reports/presentation/create_report_page.dart';
import '../features/reports/presentation/attach_expenses_page.dart';
import '../features/reports/presentation/finance/finance_payment_history_page.dart';
import '../features/reports/presentation/manager/approved_reports_page.dart';
import '../features/reports/presentation/manager/managerview_report_detail.dart';
import '../features/reports/presentation/manager/rejected_reports_page.dart';
import '../features/reports/presentation/report_details_page.dart';
import '../features/reports/presentation/report_review_page.dart';
import '../features/reports/presentation/report_list_page.dart';
import '../features/reports/presentation/manager/manager_report_list_page.dart';
import '../features/reports/presentation/manager/manager_report_review_page.dart';
import '../features/reports/presentation/finance/finance_report_list_page.dart';
import '../features/reports/presentation/finance/finance_payment_page.dart';
import '../features/auth/presentation/manager/manager_analytics_page.dart';
import '../features/common/placeholder_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (ctx) => const LoginPage(),
  '/employee': (ctx) => const EmployeeDashboard(),
  '/manager': (ctx) => const ManagerDashboard(),
  '/finance': (ctx) => const FinanceDashboard(),
  '/create-expense': (ctx) => const CreateExpensePage(),
  '/my-expenses': (ctx) => const ExpenseListPage(),
  '/expense-details': (ctx) => const ExpenseDetailsPage(),
  '/create-report': (ctx) => const CreateReportPage(),
  '/attach-expenses': (ctx) => const AttachExpensesPage(),
  '/report-review': (ctx) => const ReportReviewPage(),
  '/my-reports': (ctx) => const ReportListPage(),
  '/report-details': (_) => const ReportDetailsPage(),
  '/manager-reports': (ctx) => const ManagerReportListPage(),
  '/manager-review': (ctx) => const ManagerReportReviewPage(),
  '/manager-reportview': (context) => const ManagerReportViewPage(),
  '/approved-reports': (_) => const ApprovedReportsPage(),
  '/rejected-reports': (_) => const RejectedReportsPage(),
  '/manager-analytics': (ctx) => const ManagerAnalyticsPage(),
  '/finance-reports': (ctx) => const FinanceReportListPage(),
  '/finance-payment': (ctx) => const FinancePaymentPage(),
  '/payment-history': (ctx) => const FinancePaymentHistoryPage(),
  '/placeholder': (ctx) => const PlaceholderPage(title: 'Coming Soon'),
};
