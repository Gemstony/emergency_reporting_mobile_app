// lib/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

class UserModel {
  final String id;
  final String regNo;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? departmentId;
  final String? courseId;
  final int yearRegistered;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.regNo,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.status = AppConstants.statusActive,
    this.departmentId,
    this.courseId,
    required this.yearRegistered,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $middleName $lastName';
  String get displayName => '$firstName $lastName';
  bool get isActive => status == AppConstants.statusActive;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      regNo: data['regNo'] ?? '',
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      status: data['status'] ?? AppConstants.statusActive,
      departmentId: data['departmentId'],
      courseId: data['courseId'],
      yearRegistered: data['yearRegistered'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'regNo': regNo,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'departmentId': departmentId,
      'courseId': courseId,
      'yearRegistered': yearRegistered,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class DepartmentModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    this.status = AppConstants.statusActive,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == AppConstants.statusActive;

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Education',
      status: data['status'] ?? AppConstants.statusActive,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CourseModel {
  final String id;
  final String code;
  final String name;
  final String departmentId;
  final int duration;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.departmentId,
    required this.duration,
    this.status = AppConstants.statusActive,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == AppConstants.statusActive;

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      departmentId: data['departmentId'] ?? '',
      duration: data['duration'] ?? 0,
      status: data['status'] ?? AppConstants.statusActive,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'departmentId': departmentId,
      'duration': duration,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reporterRegNo;
  final String targetDepartmentId;
  final String category;
  final String title;
  final String description;
  final String status;
  final String response;
  final String? attachmentUrl;
  final Map<String, dynamic>? location;
  final DateTime createdAt;
  final DateTime
      updatedAt; // non‑nullable, but we supply a default in fromFirestore

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterRegNo,
    required this.targetDepartmentId,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.response,
    this.attachmentUrl,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reporterRegNo: data['reporterRegNo'] ?? '',
      targetDepartmentId: data['targetDepartmentId'] ?? '',
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      response: data['response'] ?? '',
      attachmentUrl: data['attachmentUrl'],
      location: data['location'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reporterRegNo': reporterRegNo,
      'targetDepartmentId': targetDepartmentId,
      'category': category,
      'title': title,
      'description': description,
      'status': status,
      'response': response,
      'attachmentUrl': attachmentUrl,
      if (location != null) 'location': location,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CounterModel {
  final String id;
  final Map<String, int> counts;
  final DateTime updatedAt;

  CounterModel({
    required this.id,
    required this.counts,
    required this.updatedAt,
  });

  factory CounterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    Map<String, int> counts = {};
    data.forEach((key, value) {
      if (key != 'updatedAt') {
        counts[key] = value as int;
      }
    });
    return CounterModel(
      id: doc.id,
      counts: counts,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
