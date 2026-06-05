import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/php_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider();

  final _service = PhpApiService();
  final _notificationService = NotificationService();

  List<AppNotification> _items = [];
  bool _loading = false;
  Timer? _timer;

  int unreadCount = 0;

  List<AppNotification> get items => List.unmodifiable(_items);

  Future<void> init({Duration interval = const Duration(minutes: 2)}) async {
    await _notificationService.initialize();
    await refresh();
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final items = await _service.notifications();
      final oldUnread = unreadCount;
      _items = items;
      unreadCount = items.where((n) => !n.isRead).length;
      notifyListeners();

      if (unreadCount > oldUnread) {
        await _notificationService.showLocal(
          'Home Fundi',
          'You have ${unreadCount - oldUnread} new notification(s).',
        );
      }
    } catch (_) {
      // Keep UI stable even if the API is temporarily unavailable.
    } finally {
      _loading = false;
    }
  }

  Future<void> markAllRead() async {
    await _service.markNotificationsRead();
    await refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

