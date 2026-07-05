// lib/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'NIT Emergency Report';
  static const String appVersion = '1.0.0';
  static const String instituteName = 'NIT';
  
  // Colors
  static const Color primaryColor = Color(0xFF5FA4ED);
  static const Color primaryLight = Color(0xFF8BC0F5);
  static const Color primaryDark = Color(0xFF3A7CBD);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color greyColor = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);
  
  // Font Size
  static const double fontSizeSmall = 12;
  static const double fontSizeMedium = 14;
  static const double fontSizeLarge = 16;
  static const double fontSizeTitle = 20;
  
  // Firebase Collections
  static const String usersCollection = 'user';
  static const String departmentsCollection = 'departments';
  static const String coursesCollection = 'courses';
  static const String reportsCollection = 'reports';
  static const String countersCollection = 'counters';
  
  // Report Categories
  static const String categoryAcademic = 'academic';
  static const String categoryHealth = 'health';
  static const String categorySecurity = 'security';
  static const String categoryHarassment = 'harassment';
  
  // Report Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in-progress';
  static const String statusResolved = 'resolved';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';
  static const String roleStaff = 'staff';
  
  // User Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
}