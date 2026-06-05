import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _threads = await _service.chatThreads();
      if (mounted) setState(() {});
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _threads.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
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
