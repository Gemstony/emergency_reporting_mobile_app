// lib/screens/admin/more_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers.dart';
import '../../constants.dart';
import '../../utils.dart';
import 'manage_departments.dart';
import 'manage_courses.dart';
import 'manage_users.dart';
import 'view_all_reports.dart';
import 'notifications.dart';
import 'profile_page.dart';
import 'register_student_popup.dart';
import 'register_staff_popup.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8F0FE),
              const Color(0xFFF0F4F8),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ===== SPIDER WEB PATTERN (Background) =====
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                painter: MorePageSpiderWebPainter(),
              ),

              // ===== MAIN CONTENT =====
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER WITH BACK BUTTON =====
                    Row(
                      children: [
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppConstants.primaryColor,
                              size: 24,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Options',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                                fontFamily: 'Times New Roman',
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'All management tools in one place',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== USER MANAGEMENT SECTION =====
                    _buildSectionHeader('User Management', Icons.people_outline),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildMoreAction(
                          context,
                          'Add Student',
                          Icons.person_add,
                          Colors.blue,
                          () => _showRegisterStudentPopup(context),
                        ),
                        _buildMoreAction(
                          context,
                          'Add Staff',
                          Icons.person_add_alt_1,
                          Colors.orange,
                          () => _showRegisterStaffPopup(context),
                        ),
                        _buildMoreAction(
                          context,
                          'Add Admin',
                          Icons.admin_panel_settings,
                          Colors.purple,
                          () => _navigateToTab(context, 4),
                        ),
                        _buildMoreAction(
                          context,
                          'View Users',
                          Icons.people_outline,
                          Colors.teal,
                          () => _navigateToTab(context, 4),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== ACADEMIC MANAGEMENT SECTION =====
                    _buildSectionHeader('Academic Management', Icons.school_outlined),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildMoreAction(
                          context,
                          'Departments',
                          Icons.business_outlined,
                          Colors.teal,
                          () => _navigateToTab(context, 1),
                        ),
                        _buildMoreAction(
                          context,
                          'Add Dept',
                          Icons.add_business,
                          Colors.teal,
                          () => _navigateToTab(context, 1),
                        ),
                        _buildMoreAction(
                          context,
                          'Courses',
                          Icons.book_outlined,
                          Colors.indigo,
                          () => _navigateToTab(context, 2),
                        ),
                        _buildMoreAction(
                          context,
                          'Add Course',
                          Icons.add,
                          Colors.indigo,
                          () => _navigateToTab(context, 2),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== REPORTS & NOTIFICATIONS SECTION =====
                    _buildSectionHeader('Reports & Notifications', Icons.notifications_outlined),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildMoreAction(
                          context,
                          'All Reports',
                          Icons.report_outlined,
                          Colors.red,
                          () => _navigateToTab(context, 3),
                        ),
                        _buildMoreAction(
                          context,
                          'Pending',
                          Icons.pending_outlined,
                          Colors.orange,
                          () => _navigateToTab(context, 3),
                        ),
                        _buildMoreAction(
                          context,
                          'Notifications',
                          Icons.notifications_outlined,
                          Colors.pink,
                          () => _navigateToNotifications(context),
                        ),
                        _buildMoreAction(
                          context,
                          'View All',
                          Icons.visibility_outlined,
                          Colors.blueGrey,
                          () => _navigateToTab(context, 3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== SETTINGS & PROFILE SECTION =====
                    _buildSectionHeader('Settings & Profile', Icons.settings_outlined),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildMoreAction(
                          context,
                          'Profile',
                          Icons.person_outline,
                          AppConstants.primaryColor,
                          () => _navigateToProfile(context),
                        ),
                        _buildMoreAction(
                          context,
                          'Settings',
                          Icons.settings_outlined,
                          Colors.grey,
                          () => _showComingSoon(context, 'Settings'),
                        ),
                        _buildMoreAction(
                          context,
                          'Help',
                          Icons.help_outline,
                          Colors.blueGrey,
                          () => _showComingSoon(context, 'Help'),
                        ),
                        _buildMoreAction(
                          context,
                          'Logout',
                          Icons.logout_outlined,
                          Colors.red,
                          () => _showLogoutDialog(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ===== SYSTEM INFO CARD =====
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'System Information',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow('App Version', AppConstants.appVersion),
                          _buildInfoRow('Database', 'Firebase Firestore'),
                          _buildInfoRow('Platform', 'Flutter'),
                          _buildInfoRow('Status', '🟢 Online'),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppConstants.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'System running at 75% capacity',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== FOOTER =====
                    Center(
                      child: Text(
                        '© ${DateTime.now().year} NIT Emergency Report System v${AppConstants.appVersion}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, IconData icon, {bool isLarge = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
            size: isLarge ? 22 : 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isLarge ? AppConstants.primaryColor : Colors.grey[800],
            fontFamily: isLarge ? 'Times New Roman' : null,
            letterSpacing: isLarge ? 0.5 : 0,
          ),
        ),
        const Spacer(),
        if (!isLarge)
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  // ==================== MORE ACTION BUTTON ====================
  Widget _buildMoreAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INFO ROW ====================
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION METHODS ====================
  void _navigateToTab(BuildContext context, int index) {
    Navigator.pop(context);
    context.visitAncestorElements((element) {
      if (element is StatefulElement &&
          element.state.widget.runtimeType.toString() == 'AdminDashboard') {
        element.state.setState(() {
          (element.state as dynamic)._currentIndex = index;
        });
        return false;
      }
      return true;
    });
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  // ==================== POPUP METHODS ====================
  void _showRegisterStudentPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegisterStudentPopup(),
    );
  }

  void _showRegisterStaffPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RegisterStaffPopup(),
    );
  }

  // ==================== COMING SOON ====================
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==================== LOGOUT ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontSize: 16)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ==================== SPIDER WEB PAINTER ====================
class MorePageSpiderWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.primaryColor.withOpacity(0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = size.width * 0.7;

    // Concentric circles
    for (int i = 0; i < 8; i++) {
      final radius = (maxRadius / 8) * (i + 1);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Radial lines
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * 3.14159 / 180;
      final endX = centerX + maxRadius * cos(angle);
      final endY = centerY + maxRadius * sin(angle);
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(endX, endY),
        paint,
      );
    }

    // Extra web connections
    paint.color = AppConstants.primaryColor.withOpacity(0.02);
    paint.strokeWidth = 0.8;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      for (int j = 0; j < 6; j++) {
        final r1 = (maxRadius / 6) * j;
        final r2 = (maxRadius / 6) * (j + 0.5);
        final x1 = centerX + r1 * cos(angle);
        final y1 = centerY + r1 * sin(angle);
        final x2 = centerX + r2 * cos(angle + 0.2);
        final y2 = centerY + r2 * sin(angle + 0.2);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}