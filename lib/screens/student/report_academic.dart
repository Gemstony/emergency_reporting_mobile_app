// lib/screens/student/report_academic.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

class ReportAcademicScreen extends StatefulWidget {
  final bool embedded;
  const ReportAcademicScreen({super.key, this.embedded = false});

  @override
  State<ReportAcademicScreen> createState() => _ReportAcademicScreenState();
}

class _ReportAcademicScreenState extends State<ReportAcademicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isQuickSubmitting = false;

  List<DepartmentModel> _departments = [];
  bool _loadingDepartments = true;
  String? _departmentsError;
  String? _selectedCategory;
  DepartmentModel? _selectedDepartment;

  Map<String, dynamic>? _location;
  bool _isGettingLocation = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  // Categories – must be defined before build
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': const Color(0xFF4CAF50)
    },
    {
      'name': 'Health',
      'icon': Icons.health_and_safety,
      'color': const Color(0xFFE74C3C)
    },
    {
      'name': 'Security',
      'icon': Icons.security,
      'color': const Color(0xFFF39C12)
    },
    {
      'name': 'Dean',
      'icon': Icons.account_balance,
      'color': const Color(0xFF9B59B6)
    },
  ];

  // Emergency definitions
  final Map<String, List<Map<String, String>>> _emergencies = {
    'Education': [
      {
        'title': 'Lecture Cancelled',
        'description':
            'A scheduled lecture was cancelled without prior notice, affecting student attendance and learning.'
      },
      {
        'title': 'Exam Conflict',
        'description':
            'There is a scheduling conflict between two exams or between an exam and another mandatory activity.'
      },
      {
        'title': 'Poor Teaching',
        'description':
            'The lecturer fails to deliver content effectively, uses inappropriate methods, or is unprepared.'
      },
      {
        'title': 'Missing Grades',
        'description':
            'Grades for a completed course or assignment have not been published despite the deadline passing.'
      },
      {
        'title': 'Lab Issues',
        'description':
            'Laboratory equipment is broken, unavailable, or the lab session is poorly managed.'
      },
    ],
    'Health': [
      {
        'title': 'Injury',
        'description':
            'A student or staff member has sustained a physical injury and requires immediate attention.'
      },
      {
        'title': 'Illness',
        'description':
            'A contagious or serious illness is affecting a member of the campus community.'
      },
      {
        'title': 'COVID-19 Symptom',
        'description':
            'A person on campus is showing symptoms consistent with COVID-19 (fever, cough, loss of taste).'
      },
      {
        'title': 'Mental Health Crisis',
        'description':
            'A student is experiencing a severe mental health episode requiring urgent intervention.'
      },
      {
        'title': 'Medical Emergency',
        'description':
            'A life‑threatening medical situation has occurred on campus (e.g., heart attack, severe bleeding).'
      },
    ],
    'Security': [
      {
        'title': 'Theft',
        'description':
            'A theft has occurred on campus – property has been stolen or is missing.'
      },
      {
        'title': 'Vandalism',
        'description':
            'Property has been deliberately damaged or destroyed on campus premises.'
      },
      {
        'title': 'Suspicious Person',
        'description':
            'An unknown person is acting suspiciously on campus and may pose a security risk.'
      },
      {
        'title': 'Safety Hazard',
        'description':
            'A physical hazard (e.g., broken glass, exposed wires, slippery floor) is threatening safety.'
      },
      {
        'title': 'Violence',
        'description':
            'A violent incident or threat of violence is occurring or has occurred on campus.'
      },
    ],
    'Dean': [
      {
        'title': 'Harassment',
        'description':
            'A student is being harassed (verbally, physically, or online) by another individual.'
      },
      {
        'title': 'Discrimination',
        'description':
            'A student is experiencing discrimination based on gender, race, religion, or sexual orientation.'
      },
      {
        'title': 'Academic Grievance',
        'description':
            'A student has a formal complaint about an academic decision, grading, or treatment by faculty.'
      },
      {
        'title': 'Student Welfare',
        'description':
            'A student’s well‑being is at risk due to financial hardship, housing issues, or personal problems.'
      },
      {
        'title': 'Disciplinary Issue',
        'description':
            'A student has violated a code of conduct or a disciplinary matter needs review.'
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDepartments();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadDepartments();
      if (!mounted) return;
      setState(() {
        _departments =
            adminProvider.departments.where((d) => d.isActive).toList();
        _loadingDepartments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _departmentsError = e.toString();
        _loadingDepartments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Report Issue'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loadingDepartments) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ensure categories list is available (it is)
    final categories = _categories;

    final categoryEmergencies =
        _selectedCategory != null ? _emergencies[_selectedCategory!] ?? [] : [];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the type of issue you want to report',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Category Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat['name'];
              return _buildCategoryCard(
                cat['name'] as String,
                cat['icon'] as IconData,
                cat['color'] as Color,
                isSelected,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Form (appears when category selected)
          if (_selectedCategory != null && _selectedDepartment != null)
            Container(
              key: _formKey,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: categories
                              .firstWhere((c) =>
                                  c['name'] == _selectedCategory)['color']
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          categories.firstWhere(
                              (c) => c['name'] == _selectedCategory)['icon'],
                          color: categories.firstWhere(
                              (c) => c['name'] == _selectedCategory)['color'],
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Category',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _selectedCategory!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: categories.firstWhere((c) =>
                                    c['name'] == _selectedCategory)['color'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Quick Emergency Buttons
                  if (categoryEmergencies.isNotEmpty) ...[
                    const Text(
                      'Quick Emergencies',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryEmergencies.map((emergency) {
                        return _buildEmergencyButton(emergency);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    const Text(
                      'Or fill details manually',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Department (auto-filled, disabled)
                  const Text(
                    'Department',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _departmentController,
                    enabled: false,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: const Icon(Icons.business,
                          size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Issue Title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter a brief title...',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      prefixIcon:
                          const Icon(Icons.title, size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Full Description',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in detail...',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      prefixIcon: const Icon(Icons.description,
                          size: 18, color: Colors.grey),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location (only for Health, Security, Dean)
                  if (_selectedCategory != 'Education') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Location (Optional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (_location != null)
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      setState(() => _location = null),
                                ),
                              SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  onPressed: _isGettingLocation
                                      ? null
                                      : _getCurrentLocation,
                                  icon: _isGettingLocation
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.my_location, size: 14),
                                  label: Text(
                                    _location == null
                                        ? 'Get Location'
                                        : 'Update',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _location == null
                                        ? AppConstants.primaryColor
                                        : Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    minimumSize: const Size(80, 30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_location != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.green, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _location!['address'] ??
                                          'Location captured',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'SUBMIT REPORT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  // OR divider + Call button
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final phone = _selectedDepartment!.phone.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'No phone number available for this department.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        _makePhoneCall(phone);
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text(
                        'Call Department',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.successColor,
                        side: BorderSide(color: AppConstants.successColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Category Card ----------
  Widget _buildCategoryCard(
    String category,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        DepartmentModel? newDept =
            _getDepartmentForCategory(category, authProvider);
        setState(() {
          _selectedCategory = category;
          _location = null;
          _selectedDepartment = newDept;
          _departmentController.text = newDept?.name ?? '';
        });

        if (newDept != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToForm();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No department found for category "$category".'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- Emergency Button ----------
  Widget _buildEmergencyButton(Map<String, String> emergency) {
    // Get category color
    final categoryColor = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories[0],
    )['color'] as Color;

    // Get icon based on emergency title
    IconData getIconForEmergency(String title) {
      switch (title) {
        case 'Lecture Cancelled':
        case 'Exam Conflict':
        case 'Poor Teaching':
        case 'Missing Grades':
        case 'Lab Issues':
          return Icons.school_outlined;
        case 'Injury':
        case 'Illness':
        case 'COVID-19 Symptom':
        case 'Medical Emergency':
          return Icons.medical_services_outlined;
        case 'Mental Health Crisis':
          return Icons.psychology_outlined;
        case 'Theft':
        case 'Vandalism':
        case 'Suspicious Person':
        case 'Violence':
          return Icons.security_outlined;
        case 'Safety Hazard':
          return Icons.warning_amber_outlined;
        case 'Harassment':
        case 'Discrimination':
          return Icons.report_problem_outlined;
        case 'Academic Grievance':
          return Icons.gavel_outlined;
        case 'Student Welfare':
          return Icons.favorite_outline;
        case 'Disciplinary Issue':
          return Icons.rule_outlined;
        default:
          return Icons.error_outline;
      }
    }

    final icon = getIconForEmergency(emergency['title']!);

    return InkWell(
      onTap: _isQuickSubmitting
          ? null
          : () {
              _showEmergencyConfirmation(emergency);
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withOpacity(0.12),
              categoryColor.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: categoryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: categoryColor,
            ),
            const SizedBox(width: 8),
            Text(
              emergency['title']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Confirm Emergency ----------
  void _showEmergencyConfirmation(Map<String, String> emergency) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Emergency Report',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to submit an emergency report:',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergency['title']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergency['description']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will be sent to ${_selectedDepartment?.name ?? 'the department'}.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitEmergencyReport(emergency);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child:
                const Text('Submit Emergency', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ---------- Submit Emergency ----------
  Future<void> _submitEmergencyReport(Map<String, String> emergency) async {
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No department selected.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isQuickSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      final report = ReportModel(
        id: '',
        reporterId: authProvider.currentUser?.id ?? '',
        reporterRegNo: authProvider.currentUser?.regNo ?? '',
        targetDepartmentId: _selectedDepartment!.id,
        category: _selectedCategory!,
        title: emergency['title']!,
        description: emergency['description']!,
        status: AppConstants.statusPending,
        response: '',
        attachmentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: _location,
      );

      bool success = await reportProvider.submitReport(report);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency report submitted successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        setState(() {
          _selectedCategory = null;
          _selectedDepartment = null;
          _location = null;
          _departmentController.clear();
          _titleController.clear();
          _descriptionController.clear();
        });
        if (!widget.embedded) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(reportProvider.error ?? 'Failed to submit emergency.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isQuickSubmitting = false);
      }
    }
  }

  // ---------- Helpers ----------
  DepartmentModel? _getDepartmentForCategory(
      String category, AuthProvider authProvider) {
    // Guard against empty departments list
    if (_departments.isEmpty) return null;

    final user = authProvider.currentUser;
    if (category == 'Education') {
      final deptId = user?.departmentId;
      if (deptId != null) {
        try {
          final dept = _departments.firstWhere((d) => d.id == deptId);
          return dept;
        } catch (_) {
          // fallback
        }
      }
      // fallback to first department
      return _departments.first;
    } else {
      final candidates =
          _departments.where((d) => d.category == category).toList();
      if (candidates.isNotEmpty) return candidates.first;
      return null;
    }
  }

  void _scrollToForm() {
    if (_formKey.currentContext != null) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Location, Call, Manual Submit – unchanged (included below)

  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable location in settings.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isGettingLocation = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String address = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
      if (mounted) {
        setState(() {
          _location = {
            'address': address,
            'lat': position.latitude,
            'lng': position.longitude,
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location captured!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category to auto‑fill department.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill title and description.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final report = ReportModel(
        id: '',
        reporterId: authProvider.currentUser?.id ?? '',
        reporterRegNo: authProvider.currentUser?.regNo ?? '',
        targetDepartmentId: _selectedDepartment!.id,
        category: _selectedCategory!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: AppConstants.statusPending,
        response: '',
        attachmentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: _location,
      );
      bool success = await reportProvider.submitReport(report);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedCategory = null;
            _selectedDepartment = null;
            _location = null;
            _departmentController.clear();
          });
          if (!widget.embedded) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reportProvider.error ?? 'Error submitting report'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
