// lib/providers.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'repositories.dart';
import 'utils.dart';
import 'constants.dart'; // Added missing import for AppConstants

// lib/providers.dart (only AuthProvider part – replace the entire AuthProvider class)

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  Future<bool> login(String regNo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(regNo, password);

      await SessionManager.saveUserData(
        userId: _currentUser!.id,
        regNo: _currentUser!.regNo,
        role: _currentUser!.role,
        departmentId: _currentUser!.departmentId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // lib/providers.dart (inside AuthProvider class)

// Check if user is already logged in (called on app start)
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (!isLoggedIn) return false;

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return false;

      // Fetch user data from Firestore using userId
      final user = await _repository.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    await SessionManager.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> resetPassword(
      String email, String phone, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.resetPassword(email, phone, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper: convert exceptions to user-friendly messages
  String _getUserFriendlyError(Object e) {
    if (e is FirebaseAuthException) {
      // Handle Firebase Auth specific errors
      switch (e.code) {
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'user-not-found':
          return 'No user found with these credentials.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return e.message ?? 'An error occurred. Please try again.';
      }
    } else if (e is FirebaseException) {
      // General Firebase exceptions (including Firestore)
      if (e.code == 'network-request-failed') {
        return 'Network error. Please check your internet connection.';
      }
      return e.message ?? 'An error occurred. Please try again.';
    } else if (e is Exception) {
      // Any other exception
      final msg = e.toString();
      if (msg.contains('network') ||
          msg.contains('Connection') ||
          msg.contains('timeout')) {
        return 'Network error. Please check your internet connection.';
      }
      return 'An error occurred. Please try again.';
    }
    return 'An unexpected error occurred.';
  }
}

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToReports(String departmentId) {
    _repository.getReportsForDepartment(departmentId).listen((reports) {
      _reports = reports;
      notifyListeners();
    });
  }

  void listenToUserReports(String userId) {
    _repository.getReportsByUser(userId).listen((reports) {
      _reports = reports;
      notifyListeners();
    });
  }
// In ReportProvider

  Future<bool> submitReport(ReportModel report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docRef = await _repository.submitReport(report);
      // After success, add notifications
      final notificationRepo = NotificationRepository();

      // Notification for the reporter (student)
      await notificationRepo.addNotification(
        NotificationModel(
          id: '',
          type: 'report',
          title: 'Report Submitted',
          message:
              'Your report "${report.title}" has been submitted successfully.',
          source: 'student',
          destination: report.reporterId,
          createdAt: DateTime.now(),
          relatedId: docRef.id,
          reporterRegNo: report.reporterRegNo,
          departmentId: report.targetDepartmentId,
        ),
      );

      // Notification for the department (staff)
      await notificationRepo.addNotification(
        NotificationModel(
          id: '',
          type: 'report',
          title: 'New Report Received',
          message: 'New report "${report.title}" from ${report.reporterRegNo}',
          source: 'student',
          destination: report.targetDepartmentId,
          createdAt: DateTime.now(),
          relatedId: docRef.id,
          reporterRegNo: report.reporterRegNo,
          departmentId: report.targetDepartmentId,
        ),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReportStatus(
      String reportId, String status, String response) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateReportStatus(reportId, status, response);
      // After success, add notification for the reporter
      final report = _reports.firstWhere((r) => r.id == reportId);
      final notificationRepo = NotificationRepository();

      await notificationRepo.addNotification(
        NotificationModel(
          id: '',
          type: 'report',
          title: 'Report Updated',
          message:
              'Your report "${report.title}" has been updated to ${_getStatusLabel(status)}.',
          source: 'staff',
          destination: report.reporterId,
          createdAt: DateTime.now(),
          relatedId: reportId,
          reporterRegNo: report.reporterRegNo,
          departmentId: report.targetDepartmentId,
        ),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  Future<void> loadAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getAllReports();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DepartmentModel> _departments = [];
  List<CourseModel> _courses = [];
  List<CourseModel> _allCourses = [];
  List<UserModel> _students = [];
  List<UserModel> _staff = [];
  bool _isLoading = false;
  String? _error;

  List<DepartmentModel> get departments => _departments;
  List<CourseModel> get courses => _courses;
  List<CourseModel> get allCourses => _allCourses;
  List<UserModel> get students => _students;
  List<UserModel> get staff => _staff;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add this getter
  List<UserModel> get admins => _admins; // define _admins list at top
  List<UserModel> _admins = [];

  Future<int> getNextSequence(String type) async {
    final counterRef = _firestore
        .collection(AppConstants.countersCollection)
        .doc('regCounter');
    final snapshot = await counterRef.get();
    final key = type; // 'admin', 'student', 'staff'
    int current = 0;
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      current = data[key] ?? 0;
    }
    final next = current + 1;
    await counterRef.set({key: next}, SetOptions(merge: true));
    return next;
  }

// Add this method to load admins
  Future<void> loadAdmins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _admins = await _repository.getUsersByRole(AppConstants.roleAdmin);
      print('✅ Admins loaded: ${_admins.length}'); // 👈 debug
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Error loading admins: $e');
    }
  }

// ==================== ADMIN REGISTRATION ====================
  Future<String?> registerAdmin(Map<String, dynamic> adminData,
      {String? adminId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate regNo
      String regNo =
          'NIT/ADMIN/${DateTime.now().year}/${DateTime.now().millisecondsSinceEpoch}';
      regNo = regNo.substring(0, 18);

      // Store in Firestore
      await _firestore.collection(AppConstants.usersCollection).add({
        ...adminData,
        'regNo': regNo,
        'role': AppConstants.roleAdmin,
        'status': AppConstants.statusActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Create Firebase Auth user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminData['email'],
        password: adminData['password'],
      );
      await loadAdmins();

      // Notify the admin who performed the action (if any)
      if (adminId != null) {
        final notificationRepo = NotificationRepository();
        await notificationRepo.addNotification(
          NotificationModel(
            id: '',
            type: 'user',
            title: 'Admin Registered',
            message:
                'Admin ${adminData['firstName']} ${adminData['lastName']} ($regNo) has been added.',
            source: 'staff',
            destination: adminId,
            createdAt: DateTime.now(),
            relatedId: regNo,
            reporterRegNo: regNo,
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Department Methods
  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _repository.getDepartments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerDepartment(DepartmentModel department) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerDepartment(department);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDepartment(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateDepartment(id, data);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDepartment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteDepartment(id);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDepartmentStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleDepartmentStatus(id, active);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Course Methods
  Future<void> loadAllCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCourses = await _repository.getAllCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourses(String departmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repository.getCoursesByDepartment(departmentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerCourse(CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerCourse(course);
      await loadCourses(course.departmentId);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCourse(id, data);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCourse(id);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCourseStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleCourseStatus(id, active);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // User Methods
  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _repository.getUsersByRole(AppConstants.roleStudent);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staff = await _repository.getUsersByRole(AppConstants.roleStaff);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // In AdminProvider
// ==================== STUDENT REGISTRATION ====================
  Future<String?> registerStudent(StudentData student,
      {String? adminId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String regNo = await _repository.registerStudent(student);
      await loadStudents();

      // Notify the admin (if adminId is provided)
      if (adminId != null) {
        final notificationRepo = NotificationRepository();
        await notificationRepo.addNotification(
          NotificationModel(
            id: '',
            type: 'user',
            title: 'Student Registered',
            message:
                'Student ${student.firstName} ${student.lastName} ($regNo) has been registered.',
            source: 'staff',
            destination: adminId,
            createdAt: DateTime.now(),
            relatedId: regNo,
            reporterRegNo: regNo,
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

// ==================== STAFF REGISTRATION ====================
  Future<String?> registerStaff(StaffData staff, {String? adminId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String regNo = await _repository.registerStaff(staff);
      await loadStaff();

      // Notify the admin
      if (adminId != null) {
        final notificationRepo = NotificationRepository();
        await notificationRepo.addNotification(
          NotificationModel(
            id: '',
            type: 'user',
            title: 'Staff Registered',
            message:
                'Staff ${staff.firstName} ${staff.lastName} ($regNo) has been registered.',
            source: 'staff',
            destination: adminId,
            createdAt: DateTime.now(),
            relatedId: regNo,
            reporterRegNo: regNo,
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUser(id, data);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleUserStatus(id, active);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

class StudentProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
}

class StaffProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
}

// lib/providers.dart – add this class

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to notifications for a specific destination
  void listenToNotifications(String destination) {
    _isLoading = true;
    notifyListeners();
    print('🔔 listenToNotifications called with destination: $destination');

    _firestore
        .collection(AppConstants.notificationsCollection)
        .where('destination', isEqualTo: destination)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      print(
          '📦 Received ${snapshot.docs.length} notifications for destination: $destination');
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('❌ Error in listenToNotifications: $error');
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead(String destination) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection(AppConstants.notificationsCollection)
          .where('destination', isEqualTo: destination)
          .where('isRead', isEqualTo: false)
          .get();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // lib/providers.dart – inside NotificationProvider
  void listenToAllNotifications() {
    _isLoading = true;
    notifyListeners();
    print('🔔 listenToAllNotifications called');

    _firestore
        .collection(AppConstants.notificationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      print('📦 Received ${snapshot.docs.length} notifications (all)');
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('❌ Error in listenToAllNotifications: $error');
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }
}
