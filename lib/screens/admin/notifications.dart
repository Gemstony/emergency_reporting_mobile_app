// lib/screens/admin/notifications.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        print('👤 User role: ${user.role}');
        print('👤 User ID: ${user.id}');
        print('👤 Department ID: ${user.departmentId}');

        if (user.role == AppConstants.roleAdmin) {
          // Admin sees all notifications (no destination filter)
          notificationProvider.listenToAllNotifications();
        } else if (user.role == AppConstants.roleStaff) {
          // Staff sees notifications for their department
          final destination = user.departmentId ?? user.id;
          notificationProvider.listenToNotifications(destination);
        } else {
          // Student sees personal notifications
          notificationProvider.listenToNotifications(user.id);
        }
      } else {
        print('❌ No user found');
      }
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
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final allNotifications = notificationProvider.notifications;

    // Filter by type (report or user) and search query
    final filtered = allNotifications.where((notif) {
      // Only show report and user notifications
      if (notif.type != 'report' && notif.type != 'user') return false;
      if (_selectedFilter != 'all' && notif.type != _selectedFilter)
        return false;
      if (_searchQuery.isNotEmpty) {
        return notif.title.toLowerCase().contains(_searchQuery) ||
            notif.message.toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Notifications',
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
                          '${filtered.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.done_all,
                            color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final user = authProvider.currentUser;
                          if (user != null) {
                            String destination =
                                (user.role == AppConstants.roleAdmin)
                                    ? user.id
                                    : user.departmentId ?? user.id;
                            await notificationProvider
                                .markAllAsRead(destination);
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
                              hintText: 'Search notifications...',
                              hintStyle: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
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
                // Filter chips
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                            'All', 'all', Icons.notifications_none),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'Reports', 'report', Icons.report_outlined),
                        const SizedBox(width: 8),
                        _buildFilterChip('Users', 'user', Icons.people_outline),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
              ? _buildEmptyState(_searchQuery.isNotEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notif = filtered[index];
                    return _buildNotificationCard(notif);
                  },
                ),
    );
  }

  // Filter chip widget (unchanged)
  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    final Color color = isSelected ? AppConstants.primaryColor : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryColor
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppConstants.primaryColor
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState(bool hasSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.notifications_off,
            size: 70,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 14),
          Text(
            hasSearch
                ? 'No notifications match your search'
                : 'No Notifications',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasSearch
                ? 'Try adjusting your search or filter'
                : 'You\'re all caught up!',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // Notification card (uses real NotificationModel)
  Widget _buildNotificationCard(NotificationModel notif) {
    final bool isUnread = !notif.isRead;
    final Color iconColor = _getTypeColor(notif.type);
    final IconData iconData = _getTypeIcon(notif.type);
    final String timeAgo = _getTimeAgo(notif.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isUnread
              ? AppConstants.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(iconData, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          color: isUnread ? Colors.black87 : Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notif.message,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnread ? Colors.grey[700] : Colors.grey[500],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 10, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notif.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              if (isUnread)
                IconButton(
                  icon: const Icon(
                    Icons.mark_as_unread_outlined,
                    size: 14,
                    color: AppConstants.primaryColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    await Provider.of<NotificationProvider>(context,
                            listen: false)
                        .markAsRead(notif.id);
                  },
                ),
              const SizedBox(height: 4),
              // Dismiss button (could also be implemented)
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.grey[400],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  // For now, just a visual feedback; could remove from list locally
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dismiss feature coming soon'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: type color
  Color _getTypeColor(String type) {
    switch (type) {
      case 'report':
        return Colors.red;
      case 'user':
        return Colors.green;
      default:
        return AppConstants.primaryColor;
    }
  }

  // Helper: type icon
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'report':
        return Icons.report_outlined;
      case 'user':
        return Icons.person_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  // Helper: time ago
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays > 7)
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
