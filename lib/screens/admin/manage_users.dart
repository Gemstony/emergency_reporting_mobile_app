// lib/screens/admin/manage_users.dart
import 'package:emergency_report_system/repositories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

// If AdminProvider lacks getNextSequence, provide a small extension
// fallback that derives the next sequence from current lists.
// This keeps this screen functional without modifying provider.
extension _AdminProviderSequenceExt on AdminProvider {
  Future<int> getNextSequence(String role) async {
    switch (role) {
      case 'student':
        return students.length + 1;
      case 'staff':
        return staff.length + 1;
      case 'admin':
        return admins.length + 1;
      default:
        return 1;
    }
  }
}

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentAdminId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _currentAdminId = authProvider.currentUser?.id;
      _loadAllData(adminProvider);
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  Future<void> _loadAllData(AdminProvider adminProvider) async {
    await Future.wait([
      adminProvider.loadDepartments(),
      adminProvider.loadAllCourses(),
      adminProvider.loadStudents(),
      adminProvider.loadStaff(),
      adminProvider.loadAdmins(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final students = adminProvider.students;
    final staff = adminProvider.staff;
    final admins = adminProvider.admins;

    // Filter users based on search query
    final filteredStudents = students.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.fullName.toLowerCase().contains(_searchQuery) ||
             user.regNo.toLowerCase().contains(_searchQuery) ||
             user.email.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredStaff = staff.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.fullName.toLowerCase().contains(_searchQuery) ||
             user.regNo.toLowerCase().contains(_searchQuery) ||
             user.email.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredAdmins = admins.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.fullName.toLowerCase().contains(_searchQuery) ||
             user.regNo.toLowerCase().contains(_searchQuery) ||
             user.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5FA4ED),
                const Color(0xFF3A7CBD),
                const Color(0xFF2C5F8A),
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
                        'Manage Users',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
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
                          await _loadAllData(provider);
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
                              hintText: 'Search users...',
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
                // ===== TAB BAR =====
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Students'),
                    Tab(text: 'Staff'),
                    Tab(text: 'Admins'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  labelStyle: const TextStyle(fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  indicatorSize: TabBarIndicatorSize.label,
                ),
              ],
            ),
          ),
        ),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(filteredStudents, 'student'),
                _buildUserList(filteredStaff, 'staff'),
                _buildUserList(filteredAdmins, 'admin'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final index = _tabController.index;
          if (index == 0) {
            _showRegisterStudentDialog();
          } else if (index == 1) {
            _showRegisterStaffDialog();
          } else {
            _showRegisterAdminDialog();
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== USER LIST ====================
  Widget _buildUserList(List<UserModel> users, String role) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == 'student'
                  ? Icons.people
                  : role == 'staff'
                      ? Icons.person
                      : Icons.admin_panel_settings,
              size: 70,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No ${_roleName(role).toLowerCase()} found'
                  : 'No ${_roleName(role)} Registered',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Tap + to register a new ${_roleName(role).toLowerCase()}',
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
    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<AdminProvider>(context, listen: false);
        await _loadAllData(provider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user, role);
        },
      ),
    );
  }

  String _roleName(String role) {
    switch (role) {
      case 'student':
        return 'Students';
      case 'staff':
        return 'Staff';
      case 'admin':
        return 'Admins';
      default:
        return 'Users';
    }
  }

  // ==================== USER CARD ====================
  Widget _buildUserCard(UserModel user, String role) {
    // Extract code from regNo
    String regNoParts = user.regNo;
    List<String> parts = regNoParts.split('/');
    String code = parts.length > 1 ? parts[1] : '';

    // Check if this is the first admin (cannot be deleted)
    final bool isFirstAdmin = role == 'admin' && _currentAdminId == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: user.isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: user.isActive
            ? null
            : Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: user.isActive
                  ? AppConstants.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                user.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: user.isActive
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
                  user.fullName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 10,
                      color: user.isActive ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      user.regNo,
                      style: TextStyle(
                        fontSize: 10,
                        color: user.isActive ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    if (isFirstAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                if (!user.isActive)
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
              // ===== RESET PASSWORD BUTTON =====
              IconButton(
                icon: Icon(
                  Icons.lock_reset,
                  size: 16,
                  color: Colors.orange,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _resetPassword(user),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 16,
                  color: AppConstants.primaryColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showEditUserDialog(user),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  size: 16,
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _toggleUserStatus(user),
              ),
              const SizedBox(width: 2),
              // ===== DELETE BUTTON (disabled for first admin) =====
              IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 16,
                  color: isFirstAdmin ? Colors.grey[400] : Colors.red,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: isFirstAdmin 
                    ? null 
                    : () => _confirmDeleteUser(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RESET PASSWORD ====================
  Future<void> _resetPassword(UserModel user) async {
    // Generate password: lastname@2026 (fixed year)
    final String password = '${user.lastName.toLowerCase()}@2026';
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset password for ${user.fullName}?',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New password will be:',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          password,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'User will need to change password on next login.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Call the provider to reset password
    final provider = Provider.of<AdminProvider>(context, listen: false);
    bool success = await provider.updateUser(user.id, {'password': password});

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset for ${user.fullName}'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to reset password'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  // ==================== EDIT USER ====================
  void _showEditUserDialog(UserModel user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final middleNameController = TextEditingController(text: user.middleName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit User',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(firstNameController, 'First Name'),
              _buildTextField(middleNameController, 'Middle Name'),
              _buildTextField(lastNameController, 'Last Name'),
              _buildTextField(emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(phoneController, 'Phone Number',
                  keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12))),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<AdminProvider>(context, listen: false);
              Map<String, dynamic> data = {
                'firstName': firstNameController.text.trim(),
                'middleName': middleNameController.text.trim(),
                'lastName': lastNameController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
              };
              bool success = await provider.updateUser(user.id, data);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User updated!'),
                      backgroundColor: AppConstants.successColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white),
            child: const Text('Update', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== TOGGLE / DELETE ====================
  void _toggleUserStatus(UserModel user) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    bool success = await provider.toggleUserStatus(user.id, !user.isActive);
    if (!mounted) return;
    if (success) {
      // Refresh data immediately
      await _loadAllData(provider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(user.isActive ? 'User deactivated!' : 'User activated!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete User', style: TextStyle(fontSize: 16)),
        content: Text(
          'Delete "${user.fullName}"?',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12))),
          ElevatedButton(
            onPressed: () async {
              // Close dialog immediately
              Navigator.pop(context);
              
              final provider = Provider.of<AdminProvider>(context, listen: false);
              bool success = await provider.deleteUser(user.id);
              
              if (!mounted) return;
              
              if (success) {
                // Refresh data immediately to remove user from list
                await _loadAllData(provider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User deleted successfully!'),
                      backgroundColor: AppConstants.successColor),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(provider.error ?? 'Failed to delete user'),
                      backgroundColor: AppConstants.errorColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== REGISTER STUDENT ====================
  void _showRegisterStudentDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? selectedDepartmentId;
    String? selectedCourseId;
    String selectedYear = DateTime.now().year.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final adminProvider = Provider.of<AdminProvider>(context);
          final departments = adminProvider.departments.where((d) => d.isActive).toList();
          final courses = adminProvider.allCourses
              .where((c) => c.departmentId == selectedDepartmentId && c.isActive)
              .toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Register Student',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(firstNameCtrl, 'First Name *'),
                  _buildTextField(middleNameCtrl, 'Middle Name'),
                  _buildTextField(lastNameCtrl, 'Last Name *'),
                  _buildTextField(emailCtrl, 'Email *',
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField(phoneCtrl, 'Phone *',
                      keyboardType: TextInputType.phone),
                  DropdownButtonFormField<String>(
                    value: selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Department *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: departments.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(d.name, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartmentId = value;
                        selectedCourseId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: courses.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCourseId = value),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Year *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(7, (i) {
                      int year = DateTime.now().year + i;
                      return DropdownMenuItem(
                          value: year.toString(),
                          child: Text(year.toString(), style: const TextStyle(fontSize: 12)));
                    }),
                    onChanged: (value) => setState(() => selectedYear = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12))),
              ElevatedButton(
                onPressed: () async {
                  if (firstNameCtrl.text.isEmpty ||
                      lastNameCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      phoneCtrl.text.isEmpty ||
                      selectedDepartmentId == null ||
                      selectedCourseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: AppConstants.errorColor),
                    );
                    return;
                  }
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  final course = provider.allCourses
                      .firstWhere((c) => c.id == selectedCourseId);
                  
                  // Get the next sequence number for student
                  final nextSeq = await provider.getNextSequence('student');
                  
                  final student = StudentData(
                    firstName: firstNameCtrl.text.trim(),
                    middleName: middleNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    departmentId: selectedDepartmentId!,
                    courseId: selectedCourseId!,
                    courseCode: course.code,
                    year: int.parse(selectedYear),
                  );
                  String? regNo = await provider.registerStudent(student);
                  if (!mounted) return;
                  if (regNo != null) {
                    // Refresh data to show new student
                    await _loadAllData(provider);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Student registered! RegNo: $regNo'),
                          backgroundColor: AppConstants.successColor),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white),
                child: const Text('Register', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== REGISTER STAFF ====================
  void _showRegisterStaffDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? selectedDepartmentId;
    String selectedYear = DateTime.now().year.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final adminProvider = Provider.of<AdminProvider>(context);
          final departments = adminProvider.departments.where((d) => d.isActive).toList();

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Register Staff',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(firstNameCtrl, 'First Name *'),
                  _buildTextField(middleNameCtrl, 'Middle Name'),
                  _buildTextField(lastNameCtrl, 'Last Name *'),
                  _buildTextField(emailCtrl, 'Email *',
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField(phoneCtrl, 'Phone *',
                      keyboardType: TextInputType.phone),
                  DropdownButtonFormField<String>(
                    value: selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Department *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: departments.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(d.name, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedDepartmentId = value),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Year *',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(7, (i) {
                      int year = DateTime.now().year + i;
                      return DropdownMenuItem(
                          value: year.toString(),
                          child: Text(year.toString(), style: const TextStyle(fontSize: 12)));
                    }),
                    onChanged: (value) => setState(() => selectedYear = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12))),
              ElevatedButton(
                onPressed: () async {
                  if (firstNameCtrl.text.isEmpty ||
                      lastNameCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      phoneCtrl.text.isEmpty ||
                      selectedDepartmentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields'),
                          backgroundColor: AppConstants.errorColor),
                    );
                    return;
                  }
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  final dept = provider.departments
                      .firstWhere((d) => d.id == selectedDepartmentId);
                  
                  final staff = StaffData(
                    firstName: firstNameCtrl.text.trim(),
                    middleName: middleNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    departmentId: selectedDepartmentId!,
                    departmentCode: dept.code,
                    year: int.parse(selectedYear),
                  );
                  String? regNo = await provider.registerStaff(staff);
                  if (!mounted) return;
                  if (regNo != null) {
                    // Refresh data to show new staff
                    await _loadAllData(provider);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Staff registered! RegNo: $regNo'),
                          backgroundColor: AppConstants.successColor),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white),
                child: const Text('Register', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== REGISTER ADMIN ====================
  void _showRegisterAdminDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Register Admin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(firstNameCtrl, 'First Name *'),
              _buildTextField(middleNameCtrl, 'Middle Name'),
              _buildTextField(lastNameCtrl, 'Last Name *'),
              _buildTextField(emailCtrl, 'Email *',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(phoneCtrl, 'Phone *',
                  keyboardType: TextInputType.phone),
              _buildTextField(passwordCtrl, 'Password *', obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12))),
          ElevatedButton(
            onPressed: () async {
              if (firstNameCtrl.text.isEmpty ||
                  lastNameCtrl.text.isEmpty ||
                  emailCtrl.text.isEmpty ||
                  phoneCtrl.text.isEmpty ||
                  passwordCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: AppConstants.errorColor),
                );
                return;
              }
              
              final provider = Provider.of<AdminProvider>(context, listen: false);
              
              // Get the next sequence number for admin
              final nextSeq = await provider.getNextSequence('admin');
              
              // Generate regNo for admin with sequence
              final generatedRegNo = 'NIT/ADMIN/${DateTime.now().year}/${nextSeq.toString().padLeft(4, '0')}';

              final String? registeredRegNo = await provider.registerAdmin({
                'firstName': firstNameCtrl.text.trim(),
                'middleName': middleNameCtrl.text.trim(),
                'lastName': lastNameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'password': passwordCtrl.text.trim(),
                'regNo': generatedRegNo,
                'sequence': nextSeq,
              });
              if (!mounted) return;
              if (registeredRegNo != null) {
                // Refresh data to show new admin
                await _loadAllData(provider);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Admin registered successfully! RegNo: $registeredRegNo'),
                      backgroundColor: AppConstants.successColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white),
            child: const Text('Register', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER TEXTFIELD ====================
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 12),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}