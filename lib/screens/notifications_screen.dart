import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/php_api_service.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = PhpApiService();
  List<AppNotification> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.notifications();
      _error = null;
    } on PhpApiException catch (error) {
      _error = error.message;
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead() async {
    try {
      await _service.markNotificationsRead();
      await _load();
      if (mounted) {
        context.read<NotificationProvider>().refresh();
      }
      if (mounted) showToast(context, 'Notifications marked as read.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((item) => !item.isRead).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(unread == 0 ? 'Notifications' : 'Notifications ($unread)'),
        actions: [
          IconButton(
            tooltip: 'Mark read',
            onPressed: _items.isEmpty ? null : _markRead,
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'Notifications unavailable',
                  message: _error!,
                  action: FilledButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                )
              : _items.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none,
                      title: 'No notifications',
                      message: 'Job updates and alerts will appear here.',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            leading: Icon(
                              item.isRead
                                  ? Icons.notifications_none
                                  : Icons.notifications_active,
                              color: item.isRead
                                  ? AppColors.textSecondary
                                  : AppColors.primaryBlue,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w900,
                              ),
                            ),
                            subtitle: Text(item.message),
                          );
                        },
                      ),
                    ),
    );
  }
}
