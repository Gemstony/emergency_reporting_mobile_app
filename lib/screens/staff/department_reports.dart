// lib/screens/staff/department_reports.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';
import 'report_details.dart';

class DepartmentReportsScreen extends StatefulWidget {
  final bool embedded;
  const DepartmentReportsScreen({super.key, this.embedded = false});

  @override
  State<DepartmentReportsScreen> createState() => _DepartmentReportsScreenState();
}

class _DepartmentReportsScreenState extends State<DepartmentReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      final departmentId = user?.departmentId;
      if (departmentId != null) {
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        reportProvider.listenToReports(departmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);
    final reports = reportProvider.reports;

    Widget content = reportProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : reports.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final user = authProvider.currentUser;
                  final departmentId = user?.departmentId;
                  if (departmentId != null) {
                    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
                    reportProvider.listenToReports(departmentId);
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(context, report);
                  },
                ),
              );

    if (widget.embedded) {
      return content;
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Department Reports',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final user = authProvider.currentUser;
              final departmentId = user?.departmentId;
              if (departmentId != null) {
                final reportProvider = Provider.of<ReportProvider>(context, listen: false);
                reportProvider.listenToReports(departmentId);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshed!'),
                  backgroundColor: AppConstants.successColor,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reports will appear here when submitted',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    final categoryColor = _getCategoryColor(report.category);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsScreen(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: categoryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(report.category),
                        size: 14,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getCategoryLabel(report.category),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Utils.getStatusColor(report.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(report.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Utils.getStatusColor(report.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            
            // Description
            Text(
              report.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 12,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  report.reporterRegNo,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  Utils.formatDate(report.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
                if (report.location != null) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return const Color(0xFF4CAF50);
      case 'health':
        return const Color(0xFFE74C3C);
      case 'security':
        return const Color(0xFFF39C12);
      case 'dean':
        return const Color(0xFF9B59B6);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'security':
        return Icons.security;
      case 'dean':
        return Icons.account_balance;
      default:
        return Icons.category;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'education': return 'Education';
      case 'health': return 'Health';
      case 'security': return 'Security';
      case 'dean': return 'Dean';
      default: return category;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in-progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return 'Unknown';
    }
  }
}