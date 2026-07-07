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
      // Load notifications data
      _loadNotifications();
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

  Future<void> _loadNotifications() async {
    // In a real app, you would load from a provider
    // For now, we'll use mock data
  }

  @override
  Widget build(BuildContext context) {
    // Mock notifications data
    final notifications = _getMockNotifications();
    
    // Filter notifications
    final filteredNotifications = notifications.where((notif) {
      // Filter by type
      if (_selectedFilter != 'all' && notif['type'] != _selectedFilter) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        return notif['title'].toLowerCase().contains(_searchQuery) ||
               notif['message'].toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
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
                      // Back Button
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
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
                      // Count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${filteredNotifications.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mark All Read Button
                      IconButton(
                        icon: const Icon(
                          Icons.done_all,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _markAllRead();
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
                              hintText: 'Search notifications...',
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
                // ===== FILTER CHIPS =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('All', 'all', Icons.notifications_none),
                        const SizedBox(width: 8),
                        _buildFilterChip('Reports', 'report', Icons.report_outlined),
                        const SizedBox(width: 8),
                        _buildFilterChip('Users', 'user', Icons.people_outline),
                        const SizedBox(width: 8),
                        _buildFilterChip('System', 'system', Icons.settings_outlined),
                        const SizedBox(width: 8),
                        _buildFilterChip('Unread', 'unread', Icons.mark_unread_chat_alt_outlined),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: filteredNotifications.isEmpty
          ? _buildEmptyState(_searchQuery.isNotEmpty)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notif = filteredNotifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  // ==================== FILTER CHIP ====================
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
          color: isSelected 
              ? Colors.white 
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppConstants.primaryColor 
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: isSelected ? AppConstants.primaryColor : Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppConstants.primaryColor : Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(bool hasSearch) {
    String message = hasSearch 
        ? 'No notifications match your search' 
        : 'No Notifications';
    String subMessage = hasSearch
        ? 'Try adjusting your search or filter'
        : 'You\'re all caught up!';
    
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
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NOTIFICATION CARD ====================
  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final bool isUnread = notif['isRead'] == false;
    final Color iconColor = _getTypeColor(notif['type']);
    final IconData iconData = _getTypeIcon(notif['type']);
    final String timeAgo = _getTimeAgo(notif['timestamp']);

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
              child: Icon(
                iconData,
                size: 18,
                color: iconColor,
              ),
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
                        notif['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: isUnread ? Colors.black87 : Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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
                  notif['message'],
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
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: Colors.grey[400],
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notif['type'].toUpperCase(),
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
                  icon: Icon(
                    Icons.mark_as_unread_outlined,
                    size: 14,
                    color: AppConstants.primaryColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _markAsRead(notif['id']);
                  },
                ),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.grey[400],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _dismissNotification(notif['id']);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Color _getTypeColor(String type) {
    switch (type) {
      case 'report':
        return Colors.red;
      case 'user':
        return Colors.green;
      case 'system':
        return Colors.blue;
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'report':
        return Icons.report_outlined;
      case 'user':
        return Icons.person_outline;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // ==================== ACTIONS ====================
  void _markAsRead(String id) {
    setState(() {
      // In real app, mark notification as read
      // For now, just show snackbar
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification marked as read'),
        backgroundColor: AppConstants.successColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _markAllRead() {
    setState(() {
      // In real app, mark all as read
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  void _dismissNotification(String id) {
    setState(() {
      // In real app, dismiss notification
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification dismissed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ==================== MOCK DATA ====================
  List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'id': '1',
        'title': 'New Report Submitted',
        'message': 'Student NIT/BIT/2026/1001 submitted a new academic report about exam issues.',
        'type': 'report',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': '2',
        'title': 'User Registered',
        'message': 'New staff member John Doe has been registered successfully.',
        'type': 'user',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'id': '3',
        'title': 'Report Resolved',
        'message': 'Security report #003 has been resolved by admin.',
        'type': 'report',
        'isRead': true,
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      },
      {
        'id': '4',
        'title': 'System Update',
        'message': 'Emergency Report System v2.0 has been deployed with new features.',
        'type': 'system',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '5',
        'title': 'Report Escalated',
        'message': 'Harassment report #005 has been escalated to the Dean\'s office.',
        'type': 'report',
        'isRead': true,
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '6',
        'title': 'New Admin Added',
        'message': 'Jane Smith has been added as a new system administrator.',
        'type': 'user',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '7',
        'title': 'Report Pending',
        'message': 'There are 3 pending reports waiting for your review.',
        'type': 'report',
        'isRead': true,
        'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '8',
        'title': 'System Maintenance',
        'message': 'System maintenance scheduled for Sunday at 2:00 AM.',
        'type': 'system',
        'isRead': false,
        'timestamp': DateTime.now().subtract(const Duration(days: 7)),
      },
    ];
  }
}