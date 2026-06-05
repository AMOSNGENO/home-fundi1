import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import 'chat_room.dart';

class TechnicianChatsScreen extends StatefulWidget {
  const TechnicianChatsScreen({super.key});

  @override
  State<TechnicianChatsScreen> createState() => _TechnicianChatsScreenState();
}

class _TechnicianChatsScreenState extends State<TechnicianChatsScreen> {
  final _service = PhpApiService();
  List<ChatThread> _threads = [];
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
      _threads = await _service.chatThreads();
      _error = null;
    } on PhpApiException catch (error) {
      _error = error.message;
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ChatEmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chats unavailable',
                  message: _error!,
                  actionLabel: 'Retry',
                  onAction: _load,
                )
              : _threads.isEmpty
                  ? _ChatEmptyState(
                      icon: Icons.forum_outlined,
                      title: 'No chats yet',
                      message:
                          'Accept a job or contact admin support to start chatting.',
                      actionLabel: 'Refresh',
                      onAction: _load,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _threads.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final thread = _threads[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                thread.recipientRole == 'admin'
                                    ? Icons.admin_panel_settings_outlined
                                    : Icons.person_outline,
                              ),
                            ),
                            title: Text(thread.title),
                            subtitle: Text(
                              thread.lastMessage.isEmpty
                                  ? thread.subtitle
                                  : thread.lastMessage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: thread.unreadCount == 0
                                ? const Icon(Icons.chevron_right)
                                : Badge(
                                    label: Text('${thread.unreadCount}'),
                                    child: const Icon(Icons.chevron_right),
                                  ),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    title: thread.title,
                                    subtitle: thread.subtitle,
                                    requestId: thread.requestId,
                                    recipientId: thread.recipientId,
                                  ),
                                ),
                              );
                              _load();
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onAction?.call(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 120),
          Icon(icon, size: 54, color: const Color(0xFF5B6472)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5B6472)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
