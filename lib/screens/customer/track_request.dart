import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/php_api_service.dart';
import '../technician/chat_room.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class TrackRequestScreen extends StatefulWidget {
  const TrackRequestScreen({super.key});

  @override
  State<TrackRequestScreen> createState() => _TrackRequestScreenState();
}

class _TrackRequestScreenState extends State<TrackRequestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthProvider>().user!.id;
      context.read<RequestProvider>().loadCustomerRequests(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = context
        .watch<RequestProvider>()
        .requests
        .where((r) => r.status != 'completed' && r.status != 'cancelled')
        .toList();
    final request = active.isEmpty ? null : active.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Request'),
        actions: const [
          NotificationBellButton(color: Colors.white),
        ],
      ),
      body: request == null
          ? const Center(child: Text('No active request to track.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  request.applianceName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(request.description),
                if (request.requestImageUrl != null &&
                    request.requestImageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      PhpApiService.mediaUrl(request.requestImageUrl),
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                if (request.estimatedCost != null &&
                    request.estimatedCost!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(money(request.estimatedCost)),
                    subtitle: const Text('Quoted price'),
                  ),
                ],
                if (request.technicianName != null) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.engineering_outlined),
                    ),
                    title: Text(request.technicianName!),
                    subtitle: const Text('Assigned technician'),
                    trailing: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: request.technicianId == null || request.technicianId!.isEmpty
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(
                                    title: request.technicianName!,
                                    subtitle: request.applianceName,
                                    requestId: request.id,
                                    recipientId: request.technicianId!,
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Debug: Show coordinates
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug: Coordinates',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        'Latitude: ${request.latitude}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Longitude: ${request.longitude}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (request.latitude != null && request.longitude != null) ...[
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            request.latitude!,
                            request.longitude!,
                          ),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.tricomtechnologies.home_fundi',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  request.latitude!,
                                  request.longitude!,
                                ),
                                width: 44,
                                height: 44,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Color(0xFFFF2E2E),
                                  size: 42,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No location coordinates for this request.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                for (final status in AppConstants.statuses.where(
                  (s) => s != 'cancelled',
                ))
                  ListTile(
                    leading: Icon(
                      _statusReached(request.status, status)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _statusReached(request.status, status)
                          ? Colors.green
                          : null,
                    ),
                    title: Text(readableStatus(status)),
                    subtitle: status == request.status
                        ? const Text('Current status')
                        : null,
                  ),
              ],
            ),
    );
  }

  bool _statusReached(String current, String status) {
    final order = ['pending', 'accepted', 'in_progress', 'completed'];
    return order.indexOf(current) >= order.indexOf(status);
  }
}
