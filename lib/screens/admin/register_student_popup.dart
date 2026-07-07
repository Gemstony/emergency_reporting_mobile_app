// lib/screens/admin/register_student_popup.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../repositories.dart';
import '../../models.dart';
import '../../utils.dart';

class RegisterStudentPopup extends StatefulWidget {
  const RegisterStudentPopup({super.key});

  @override
  State<RegisterStudentPopup> createState() => _RegisterStudentPopupState();
}

class _RegisterStudentPopupState extends State<RegisterStudentPopup> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _courseSearchController = TextEditingController();
  
  String? _selectedDepartmentId;
  String? _selectedCourseId;
  String? _selectedCourseCode;
  int? _selectedYear;
  bool _isRegistering = false;
  String? _generatedRegNo;
  String? _generatedPassword;
  
  List<CourseModel> _filteredCourses = [];
  bool _showCourseDropdown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDepartments();
      adminProvider.loadAllCourses();
      _selectedYear = Utils.getCurrentYear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: AppConstants.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Register Student',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            
            // Success Message (when registered)
            if (_generatedRegNo != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.successColor),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppConstants.successColor,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Student Registered Successfully!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.successColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Reg No: $_generatedRegNo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Password: $_generatedPassword',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _generatedRegNo = null;
                                _generatedPassword = null;
                                _firstNameController.clear();
                                _middleNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                _phoneController.clear();
                                _selectedDepartmentId = null;
                                _selectedCourseId = null;
                                _selectedCourseCode = null;
                                _courseSearchController.clear();
                                _filteredCourses = [];
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                              side: const BorderSide(color: AppConstants.primaryColor),
                            ),
                            child: const Text('Register Another'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // Registration Form
            if (_generatedRegNo == null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Department Dropdown
                      const Text(
                        'Department *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartmentId,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Select Department',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.business, size: 20),
                        ),
                        items: adminProvider.departments.where((d) => d.isActive).map((dept) {
                          return DropdownMenuItem(
                            value: dept.id,
                            child: Text(dept.name, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartmentId = value;
                            _selectedCourseId = null;
                            _selectedCourseCode = null;
                            _courseSearchController.clear();
                            _filteredCourses = [];
                          });
                          if (value != null) {
                            adminProvider.loadCourses(value);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Course Search with Filter
                      const Text(
                        'Course *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _courseSearchController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Search Course...',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                suffixIcon: _courseSearchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            _courseSearchController.clear();
                                            _filteredCourses = [];
                                            _showCourseDropdown = false;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _showCourseDropdown = value.isNotEmpty;
                                  _filteredCourses = adminProvider.courses.where((course) {
                                    return course.isActive &&
                                        (course.code.toLowerCase().contains(value.toLowerCase()) ||
                                         course.name.toLowerCase().contains(value.toLowerCase()));
                                  }).toList();
                                });
                              },
                              onTap: () {
                                setState(() {
                                  _showCourseDropdown = true;
                                  _filteredCourses = adminProvider.courses.where((c) => c.isActive).toList();
                                });
                              },
                            ),
                            if (_showCourseDropdown && _filteredCourses.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: 150,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = _filteredCourses[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        '${course.code} - ${course.name}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedCourseId = course.id;
                                          _selectedCourseCode = course.code;
                                          _courseSearchController.text = '${course.code} - ${course.name}';
                                          _filteredCourses = [];
                                          _showCourseDropdown = false;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (_selectedCourseId != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.1),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppConstants.successColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Selected: ${_selectedCourseCode}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Year Selection
                      const Text(
                        'Year *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                            items: Utils.getAvailableYears().map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Personal Information
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // First Name
                      TextField(
                        controller: _firstNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'First Name *',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: 'Enter first name',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.person, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Middle Name
                      TextField(
                        controller: _middleNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Middle Name',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: 'Enter middle name',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Last Name
                      TextField(
                        controller: _lastNameController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Last Name *',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: 'Enter last name',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.person, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Email
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: 'example@nit.ac.tz',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.email, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Phone
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 12),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          labelStyle: const TextStyle(fontSize: 12),
                          hintText: '0712345678',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(Icons.phone, size: 20),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Reg No will be auto-generated as NIT/COURSE/YEAR/XXXX\n'
                                'Default Password: lastname@year',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _registerStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'REGISTER STUDENT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _registerStudent() async {
    // Validation
    if (_selectedDepartmentId == null ||
        _selectedCourseId == null ||
        _selectedCourseCode == null ||
        _selectedYear == null ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    
    if (!Utils.isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    
    if (!Utils.isValidPhone(_phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (10-15 digits)'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isRegistering = true;
    });
    
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    
    final student = StudentData(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      departmentId: _selectedDepartmentId!,
      courseId: _selectedCourseId!,
      courseCode: _selectedCourseCode!,
      year: _selectedYear!,
    );
    
    String? regNo = await adminProvider.registerStudent(student);
    
    setState(() {
      _isRegistering = false;
      if (regNo != null) {
        _generatedRegNo = regNo;
        _generatedPassword = Utils.generatePassword(
          _lastNameController.text.trim(),
          _selectedYear!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student registered successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.error ?? 'An error occurred'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    });
  }
}