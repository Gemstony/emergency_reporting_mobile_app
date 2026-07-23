// lib/screens/admin/manage_departments.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() =>
      _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // 👈 new
  final TextEditingController _searchController = TextEditingController();

  bool _isAdding = false;
  String? _editingId;
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = ['Education', 'Health', 'Security', 'Dean'];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Education':
        return const Color(0xFF4CAF50);
      case 'Health':
        return const Color(0xFFE74C3C);
      case 'Security':
        return const Color(0xFFF39C12);
      case 'Dean':
        return const Color(0xFF9B59B6);
      default:
        return Colors.grey;
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10,15}$').hasMatch(phone);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.loadDepartments();
      provider.loadAllCourses();
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    final filteredDepartments = adminProvider.departments.where((dept) {
      if (_searchQuery.isEmpty) return true;
      return dept.name.toLowerCase().contains(_searchQuery) ||
          dept.code.toLowerCase().contains(_searchQuery) ||
          dept.description.toLowerCase().contains(_searchQuery) ||
          dept.category.toLowerCase().contains(_searchQuery) ||
          dept.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
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
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        'Departments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${filteredDepartments.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final provider = Provider.of<AdminProvider>(context,
                              listen: false);
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
                // Search
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Container(
                    height: 36,
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
                        Icon(Icons.search, color: Colors.grey[400], size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search departments...',
                              hintStyle: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey[400], size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _searchController.clear(),
                          ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
                // Info Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.business_outlined,
                                size: 12, color: Colors.white.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              'Active: ${adminProvider.departments.where((d) => d.isActive).length}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tap department to view courses',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
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
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredDepartments.isEmpty
              ? _buildEmptyState(_searchQuery.isNotEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDepartments.length,
                  itemBuilder: (context, index) {
                    final dept = filteredDepartments[index];
                    return _buildDepartmentCard(dept);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDepartmentDialog(),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(bool hasSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.business,
            size: 70,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch ? 'No departments found' : 'No Departments Registered',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 6),
            Text(
              'Tap + to add a new department',
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

  // ==================== DEPARTMENT CARD ====================
  Widget _buildDepartmentCard(DepartmentModel dept) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final departmentCourses = adminProvider.allCourses
        .where((c) => c.departmentId == dept.id && c.isActive)
        .toList();
    final categoryColor = _getCategoryColor(dept.category);
    final isEducation = dept.category == 'Education';

    return GestureDetector(
      onTap: () {
        _showDepartmentCoursesPopup(dept, departmentCourses);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dept.isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: dept.isActive
              ? Border.all(color: categoryColor.withOpacity(0.3), width: 1)
              : Border.all(color: Colors.red.withOpacity(0.3)),
          gradient: dept.isActive
              ? LinearGradient(
                  colors: [
                    Colors.white,
                    categoryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dept.code.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              dept.isActive ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      // Description
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 10,
                              color: dept.isActive
                                  ? Colors.grey[500]
                                  : Colors.grey[400]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              dept.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: dept.isActive
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // 👇 Phone row
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 10,
                              color: dept.isActive
                                  ? Colors.grey[500]
                                  : Colors.grey[400]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              dept.phone.isEmpty
                                  ? 'No phone number'
                                  : dept.phone,
                              style: TextStyle(
                                fontSize: 10,
                                color: dept.isActive
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Category badge
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label_outlined,
                                size: 10, color: categoryColor),
                            const SizedBox(width: 2),
                            Text(
                              dept.category,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!dept.isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
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
                // Course count badge
                if (departmentCourses.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.book_outlined,
                            size: 12, color: AppConstants.primaryColor),
                        const SizedBox(width: 3),
                        Text(
                          '${departmentCourses.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
                // Action menu
                PopupMenuButton<String>(
                  icon:
                      const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditDepartmentDialog(dept);
                        break;
                      case 'toggle':
                        _toggleDepartmentStatus(dept);
                        break;
                      case 'delete':
                        _confirmDeleteDepartment(dept);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              size: 18, color: AppConstants.primaryColor),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            dept.isActive ? Icons.block : Icons.check_circle,
                            size: 18,
                            color: dept.isActive ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Text(dept.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Courses row – only for Education
            if (isEducation && departmentCourses.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 6),
              SizedBox(
                height: 26,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: departmentCourses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final course = departmentCourses[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            course.code.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '(${course.duration}y)',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (!isEducation) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Courses can only be added to Education departments',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ] else if (departmentCourses.isEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'No courses registered for this department',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== DEPARTMENT COURSES POPUP ====================
  void _showDepartmentCoursesPopup(
      DepartmentModel dept, List<CourseModel> courses) {
    final isEducation = dept.category == 'Education';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dept.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        Text(
                          '${courses.length} Course(s) · ${dept.category}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 6),
              // Course List
              if (courses.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 50,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No courses available',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEducation
                              ? 'Tap "Add Course" to create one'
                              : 'Courses can only be added to Education departments',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontStyle: isEducation
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              course.code.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Duration: ${course.duration} years',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: course.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            course.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color:
                                  course.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 6),
              if (isEducation)
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddCourseForDepartment(dept);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'ADD COURSE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ADD COURSE FOR DEPARTMENT ====================
  void _showAddCourseForDepartment(DepartmentModel dept) {
    // (unchanged – keep your existing implementation)
  }

  // ==================== ADD DEPARTMENT DIALOG ====================
  void _showAddDepartmentDialog() {
    _codeController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _phoneController.clear();
    _selectedCategory = null;
    _editingId = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Add New Department',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _codeController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Code *',
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
                        labelText: 'Department Name *',
                        labelStyle: TextStyle(fontSize: 12),
                        hintText: 'e.g., Information Technology',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(fontSize: 12),
                        hintText: 'Brief description of the department',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 👇 Phone number field
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(fontSize: 12),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(fontSize: 12),
                        hintText: 'e.g., 0712345678',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.phone, size: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(cat),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  cat,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: _isAdding ? null : _addDepartment,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== EDIT DEPARTMENT DIALOG ====================
  void _showEditDepartmentDialog(DepartmentModel dept) {
    _codeController.text = dept.code;
    _nameController.text = dept.name;
    _descriptionController.text = dept.description;
    _phoneController.text = dept.phone;
    _selectedCategory = dept.category;
    _editingId = dept.id;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Edit Department',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _codeController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Code *',
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
                        labelText: 'Department Name *',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      style: const TextStyle(fontSize: 12),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.phone, size: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(cat),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  cat,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: _isAdding ? null : _updateDepartment,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Update', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== TOGGLE / DELETE ====================
  void _toggleDepartmentStatus(DepartmentModel dept) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    bool success =
        await adminProvider.toggleDepartmentStatus(dept.id, !dept.isActive);

    if (!mounted) return;

    if (success) {
      await adminProvider.loadDepartments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dept.isActive
              ? 'Department deactivated successfully!'
              : 'Department activated successfully!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  void _confirmDeleteDepartment(DepartmentModel dept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete "${dept.name}"?',
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
              bool success = await adminProvider.deleteDepartment(dept.id);

              if (!mounted) return;

              if (success) {
                await adminProvider.loadDepartments();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Department deleted successfully!'),
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

  // ==================== ADD DEPARTMENT ====================
  Future<void> _addDepartment() async {
    // Validate required fields
    if (_codeController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Code and Name'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    // Optional phone validation
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (10-15 digits)'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final department = DepartmentModel(
      id: '',
      code: _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      phone: phone,
      createdAt: DateTime.now(),
    );

    bool success = await adminProvider.registerDepartment(department);

    if (!mounted) return;

    setState(() {
      _isAdding = false;
    });

    if (success) {
      await adminProvider.loadDepartments();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Department added successfully!'),
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

  // ==================== UPDATE DEPARTMENT ====================
  Future<void> _updateDepartment() async {
    if (_editingId == null) return;

    if (_codeController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill Code and Name'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (10-15 digits)'),
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
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory!,
      'phone': phone,
    };

    bool success = await adminProvider.updateDepartment(_editingId!, data);

    if (!mounted) return;

    setState(() {
      _isAdding = false;
    });

    if (success) {
      await adminProvider.loadDepartments();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Department updated successfully!'),
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
