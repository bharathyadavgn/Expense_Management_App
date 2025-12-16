# Employee Expense Management App (Flutter)
A multi-role Expense Management & Reimbursement mobile application built using Flutter, Riverpod, and SQLite, implementing a real-world enterprise approval and payment workflow.

# Project Overview
This application simulates an end-to-end expense reimbursement system involving three roles:
Employee – creates expenses and submits reports
Manager – reviews, approves or rejects reports
Finance – processes approved reports and marks payments
Expense Workflow
Draft → Submitted → Approved → Pending Payment → Paid
                  ↘ Rejected → Re-submitted

All data is stored locally using SQLite, and state is managed using Riverpod for scalability and predictability.

# Features
## Employee
Create expenses with:
Amount, category, date
Receipt image (camera / gallery)
Description
Create expense reports with multiple expenses
Submit reports for approval
View report status and manager comments
Re-submit rejected reports with clarification

## Manager
View pending expense reports
Review:
Expenses list
Receipt image preview (zoom enabled)
Submission details
Approve or reject reports (comment mandatory on rejection)
View:
Approved (Pending Payment)
Rejected reports
Team analytics:
Reports by status
Spending by category
Spending by employee

## Finance
View approved reports awaiting payment
Review expense details before payment
Process mock payments
Mark reports as Paid
View payment history


## Architecture
# The project follows a Clean Architecture-inspired layered structure:
# Presentation Layer (Flutter UI)
Role-based dashboards
Responsive layouts
Reusable UI components
# State Management Layer (Riverpod)
authProvider
expenseProvider
reportProvider
# Domain Layer
Entities:
User
Expense
Report
Payment
Business rules:
Role permissions
Approval workflow
Validation logic
# Data Layer (SQLite)
DAO-based access
Normalized relational schema
Full status history tracking

# Database Schema
# Tables
# users
id, name, role, manager_id, email, phone
# reports
id, title, purpose, user_id, total_amount, status, submission_date
# expenses
id, report_id, user_id, amount, category, date, merchant, description, receipt_path
# report_status_history
id, report_id, status, actor_id, comment, timestamp, is_read
# payments
id, report_id, finance_user_id, transaction_id, amount, date, status

# Payment Handling
Mock payment gateway implemented
Simulated delay and transaction ID generation
Payments stored in SQLite
Reports updated to Paid status
This approach avoids external dependencies.

# How to Test
Login as Manager → Approve report
Login as Finance → Process payment
Payment history updates automatically

# Screens Implemented
Employee
Dashboard
Create Expense
Create Report
My Expenses
My Reports
Report Details (with resubmission)
Manager
Dashboard
Pending Reports
Approved Reports
Rejected Reports
Report Review
Report View (read-only)
Analytics
Finance
Dashboard
Pending Payments
Payment Processing
Payment History

# Setup Instructions
git clone [<repository-url>](https://github.com/bharathyadavgn/Expense_Management_App)
flutter pub get
flutter run

# Requirements
Flutter SDK ^3.x to 4.0
Android Studio
Android Emulator or physical device
No API keys or backend setup required.
flutter pub get
flutter run

## Test Credentials
Role
Username
Password
Employee
emp1
emp1
Manager
mgr1
mgr1
Finance
fin1
fin1

# Assumptions
Each employee has one manager
One report can contain multiple expenses
Payments are always successful (mock)
Local-only persistence (no backend)

## Scalability Plan
# If scaled to production:
10,000+ Employees
Replace SQLite with PostgreSQL / Firebase
Introduce pagination & lazy loading
Backend-driven role access

# Multiple Departments / Branches
Add department & branch tables
Role-based filtering
Manager hierarchy support

# Real-Time Notifications
Firebase Cloud Messaging (FCM)
WebSocket or event-based backend
In-app notification center

# Cloud Sync & Offline Support
REST APIs + local cache
Sync queues for offline changes
Conflict resolution strategies

# Future Enhancements
Backend integration (REST / Firebase)
Push notifications
Admin role & dashboards
Offline sync indicators
PDF export of reports
Unit & widget tests

# Trade-offs
Decisions made and Reason
# Riverpod
Scalable, testable state management
# SQLite
Simple local persistence
# Mock payment
Faster, reliable
No backend
Focus on workflow & architecture

# Challenges Faced
# Complex Workflow Management
Solved using a centralized report_status_history table

# Multi-Role UI Handling
Role-based navigation with Riverpod state

# Data Consistency
Single source of truth via providers
Explicit refresh after key actions

# Estimated Effort
75–80 hours, including:
Architecture design
Database Schema
State management
Workflow implementation
Debugging & refinements
Documentation

![Expense_Management_App_architecture](https://github.com/user-attachments/assets/3cb001a5-e3cb-4457-ae95-5086ea5ebf5a)
