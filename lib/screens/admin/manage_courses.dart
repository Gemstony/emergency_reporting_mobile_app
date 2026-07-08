// lib/screens/admin/manage_courses.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedDepartmentId;
  bool _isAdding = false;
  String? _editingId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDepartments();
      adminProvider.loadAllCourses();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    
    // Filter courses based on search query
    final filteredCourses = adminProvider.allCourses.where((course) {
      if (_searchQuery.isEmpty) return true;
      return course.name.toLowerCase().contains(_searchQuery) ||
             course.code.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5FA4ED),
                Color(0xFF3A7CBD),
                Color(0xFF2C5F8A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ===== HEADER ROW =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        'Manage Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      // Count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${filteredCourses.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Refresh Button
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final provider = Provider.of<AdminProvider>(context, listen: false);
                          await provider.loadDepartments();
                          await provider.loadAllCourses();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Refreshed!'),
                                backgroundColor: AppConstants.successColor,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // ===== SEARCH BAR =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search courses...',
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 2),
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: 14,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredCourses.isEmpty
              ? _buildEmptyState(_searchQuery.isNotEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return _buildCourseCard(course);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(bool hasSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.book,
            size: 70,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No courses found' : 'No Courses Registered',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 6),
            Text(
              'Tap + to add a new course',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== COURSE CARD ====================
  Widget _buildCourseCard(CourseModel course) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    // Get department name from the list
    final department = adminProvider.departments.firstWhere(
      (d) => d.id == course.departmentId,
      orElse: () => DepartmentModel(
        id: course.departmentId,
        code: '?',
        name: 'Unknown',
        category: 'Unknown',
        description: '',
        createdAt: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: course.isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: course.isActive
            ? null
            : Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: course.isActive
                  ? AppConstants.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                course.code.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: course.isActive
                      ? AppConstants.primaryColor
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: course.isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 10,
                      color: course.isActive ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      department.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: course.isActive ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${course.duration} yrs',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!course.isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'INACTIVE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 16,
                  color: AppConstants.primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showEditCourseDialog(course),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(
                  course.isActive ? Icons.block : Icons.check_circle,
                  size: 16,
                  color: course.isActive ? Colors.orange : Colors.green,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _toggleCourseStatus(course),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteCourse(course),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ADD COURSE DIALOG ====================
  void _showAddCourseDialog() {
    _codeController.clear();
    _nameController.clear();
    _durationController.clear();
    _selectedDepartmentId = null;
    _editingId = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Course',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, _) {
              final activeDepartments =
                  adminProvider.departments.where((d) => d.isActive).toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Select Department *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: activeDepartments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(
                          dept.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course Code *',
                      labelStyle: TextStyle(fontSize: 12),
                      hintText: 'e.g., BIT',
                      hintStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course Name *',
                      labelStyle: TextStyle(fontSize: 12),
                      hintText: 'e.g., Bachelor of IT',
                      hintStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (Years) *',
                      labelStyle: TextStyle(fontSize: 12),
                      hintText: 'e.g., 3',
                      hintStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: _isAdding ? null : _addCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Add', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT COURSE DIALOG ====================
  void _showEditCourseDialog(CourseModel course) {
    _codeController.text = course.code;
    _nameController.text = course.name;
    _durationController.text = course.duration.toString();
    _selectedDepartmentId = course.departmentId;
    _editingId = course.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Course',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, _) {
              final activeDepartments =
                  adminProvider.departments.where((d) => d.isActive).toList();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Department *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: activeDepartments.map((dept) {
                      return DropdownMenuItem(
                        value: dept.id,
                        child: Text(
                          dept.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course Code *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course Name *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (Years) *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: _isAdding ? null : _updateCourse,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: _isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Update', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== TOGGLE COURSE STATUS ====================
  void _toggleCourseStatus(CourseModel course) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    bool success =
        await adminProvider.toggleCourseStatus(course.id, !course.isActive);

    if (!mounted) return;
    
    if (success) {
      // Refresh data
      await adminProvider.loadAllCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(course.isActive
              ? 'Course deactivated successfully!'
              : 'Course activated successfully!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  // ==================== DELETE COURSE ====================
  void _confirmDeleteCourse(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "${course.name}"?',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              bool success = await adminProvider.deleteCourse(course.id);

              if (!mounted) return;
              
              if (success) {
                // Refresh data
                await adminProvider.loadAllCourses();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course deleted successfully!'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== ADD COURSE ====================
  Future<void> _addCourse() async {
    if (_selectedDepartmentId == null ||
        _codeController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final course = CourseModel(
      id: '',
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      departmentId: _selectedDepartmentId!,
      duration: int.parse(_durationController.text.trim()),
      createdAt: DateTime.now(),
    );

    bool success = await adminProvider.registerCourse(course);

    if (!mounted) return;

    setState(() {
      _isAdding = false;
    });

    if (success) {
      // Refresh data
      await adminProvider.loadAllCourses();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course added successfully!'),
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
  }

  // ==================== UPDATE COURSE ====================
  Future<void> _updateCourse() async {
    if (_editingId == null) return;

    if (_selectedDepartmentId == null ||
        _codeController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    Map<String, dynamic> data = {
      'code': _codeController.text.trim().toUpperCase(),
      'name': _nameController.text.trim(),
      'departmentId': _selectedDepartmentId,
      'duration': int.parse(_durationController.text.trim()),
    };

    bool success = await adminProvider.updateCourse(_editingId!, data);

    if (!mounted) return;

    setState(() {
      _isAdding = false;
    });

    if (success) {
      // Refresh data
      await adminProvider.loadAllCourses();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course updated successfully!'),
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
  }
}