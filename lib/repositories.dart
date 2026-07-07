// lib/repositories.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'models.dart';
import 'utils.dart';
import 'constants.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // lib/repositories.dart (inside AuthRepository class)

// Get user by ID from Firestore
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> login(String regNo, String password) async {
    try {
      regNo = regNo.trim().toUpperCase();
      QuerySnapshot userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('regNo', isEqualTo: regNo)
          .limit(1)
          .get();
      if (userQuery.docs.isEmpty) {
        throw Exception('Username not registered');
      }

      final userData = userQuery.docs.first;
      final status =
          userData.get('status') as String? ?? AppConstants.statusActive;

      if (status == AppConstants.statusInactive) {
        throw Exception('Account is deactivated. Please contact admin.');
      }

      final email = userData.get('email') as String;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return UserModel.fromFirestore(userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Incorrect password');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> resetPassword(
      String email, String phone, String newPassword) async {
    try {
      QuerySnapshot userQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Email or phone number is incorrect');
      }

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Department CRUD
  Future<String> registerDepartment(DepartmentModel department) async {
    DocumentReference docRef = await _firestore
        .collection(AppConstants.departmentsCollection)
        .add(department.toFirestore());
    return docRef.id;
  }

  Future<void> updateDepartment(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.departmentsCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteDepartment(String id) async {
    await _firestore
        .collection(AppConstants.departmentsCollection)
        .doc(id)
        .delete();
  }

  Future<void> toggleDepartmentStatus(String id, bool active) async {
    await _firestore
        .collection(AppConstants.departmentsCollection)
        .doc(id)
        .update({
      'status':
          active ? AppConstants.statusActive : AppConstants.statusInactive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<DepartmentModel>> getDepartments() async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.departmentsCollection)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => DepartmentModel.fromFirestore(doc))
        .toList();
  }

  // Course CRUD
  Future<String> registerCourse(CourseModel course) async {
    DocumentReference docRef = await _firestore
        .collection(AppConstants.coursesCollection)
        .add(course.toFirestore());
    return docRef.id;
  }

  Future<void> updateCourse(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.coursesCollection)
        .doc(id)
        .update(data);
  }

  // In repositories.dart (AdminRepository class)

  Future<void> deleteCourse(String id) async {
    await _firestore
        .collection(AppConstants.coursesCollection)
        .doc(id)
        .delete();
  }

  Future<void> toggleCourseStatus(String id, bool active) async {
    await _firestore.collection(AppConstants.coursesCollection).doc(id).update({
      'status':
          active ? AppConstants.statusActive : AppConstants.statusInactive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<CourseModel>> getCoursesByDepartment(String departmentId) async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.coursesCollection)
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
  }

  Future<List<CourseModel>> getAllCourses() async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.coursesCollection)
        .orderBy('code')
        .get();

    return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
  }

  // Register Student with new format: NIT/COURSE/YEAR/1001+
  Future<String> registerStudent(StudentData student) async {
    // Get next sequence starting from 1001
    int sequence = await _getNextSequence(student.courseCode, student.year,
        isStudent: true);

    String regNo = Utils.generateRegNo(
      code: student.courseCode,
      year: student.year,
      sequence: sequence,
      isStudent: true,
    );

    String password = Utils.generatePassword(student.lastName, student.year);

    try {
      // Create Firebase Auth user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: student.email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to create auth user: $e');
    }

    Map<String, dynamic> userData = {
      'regNo': regNo,
      'firstName': student.firstName,
      'middleName': student.middleName,
      'lastName': student.lastName,
      'email': student.email,
      'phone': student.phone,
      'role': AppConstants.roleStudent,
      'status': AppConstants.statusActive,
      'departmentId': student.departmentId,
      'courseId': student.courseId,
      'yearRegistered': student.year,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(AppConstants.usersCollection).add(userData);
    await _updateCounter(student.courseCode, student.year, sequence);

    return regNo;
  }

  // Register Staff with new format: NIT/DEPT/YEAR/0001+
  Future<String> registerStaff(StaffData staff) async {
    // Get next sequence starting from 1 (0001)
    int sequence = await _getNextSequence(staff.departmentCode, staff.year,
        isStudent: false);

    String regNo = Utils.generateRegNo(
      code: staff.departmentCode,
      year: staff.year,
      sequence: sequence,
      isStudent: false,
    );

    String password = Utils.generatePassword(staff.lastName, staff.year);

    try {
      // Create Firebase Auth user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: staff.email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to create auth user: $e');
    }
    Map<String, dynamic> userData = {
      'regNo': regNo,
      'firstName': staff.firstName,
      'middleName': staff.middleName,
      'lastName': staff.lastName,
      'email': staff.email,
      'phone': staff.phone,
      'role': AppConstants.roleStaff,
      'status': AppConstants.statusActive,
      'departmentId': staff.departmentId,
      'yearRegistered': staff.year,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(AppConstants.usersCollection).add(userData);
    await _updateCounter(staff.departmentCode, staff.year, sequence);

    return regNo;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .update(data);
  }

  Future<void> deleteUser(String id) async {
    await _firestore.collection(AppConstants.usersCollection).doc(id).delete();
  }

  Future<void> toggleUserStatus(String id, bool active) async {
    await _firestore.collection(AppConstants.usersCollection).doc(id).update({
      'status':
          active ? AppConstants.statusActive : AppConstants.statusInactive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role)
        .orderBy('firstName')
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('firstName')
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get next sequence number
  Future<int> _getNextSequence(String code, int year,
      {bool isStudent = false}) async {
    DocumentReference counterRef = _firestore
        .collection(AppConstants.countersCollection)
        .doc('regCounter');

    DocumentSnapshot snapshot = await counterRef.get();
    String key = '$code/$year';
    int startSequence = isStudent
        ? Utils.getStudentStartSequence()
        : Utils.getStaffStartSequence();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey(key)) {
        return (data[key] as int) + 1;
      }
    }

    return startSequence;
  }

  Future<void> _updateCounter(String code, int year, int sequence) async {
    DocumentReference counterRef = _firestore
        .collection(AppConstants.countersCollection)
        .doc('regCounter');

    String key = '$code/$year';
    await counterRef.set({
      key: sequence,
    }, SetOptions(merge: true));
  }
}

class ReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> submitReport(ReportModel report) async {
    await _firestore.collection(AppConstants.reportsCollection).add(
          report.toFirestore(),
        );
  }

  Future<String> uploadAttachment(File file) async {
    String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Stream<List<ReportModel>> getReportsForDepartment(String departmentId) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('targetDepartmentId', isEqualTo: departmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<ReportModel>> getReportsByUser(String userId) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateReportStatus(
      String reportId, String status, String response) async {
    await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .update({
      'status': status,
      'response': response,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ReportModel>> getAllReports() async {
    QuerySnapshot snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }
}

// Data Classes for Registration
class StudentData {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String departmentId;
  final String courseId;
  final String courseCode;
  final int year;

  StudentData({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.courseId,
    required this.courseCode,
    required this.year,
  });
}

class StaffData {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String departmentId;
  final String departmentCode;
  final int year;

  StaffData({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.departmentId,
    required this.departmentCode,
    required this.year,
  });
}
