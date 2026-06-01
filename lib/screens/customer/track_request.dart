import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

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
      appBar: AppBar(title: const Text('Track Request')),
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
                if (request.technicianName != null) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.engineering_outlined),
                    ),
                    title: Text(request.technicianName!),
                    subtitle: const Text('Assigned technician'),
                  ),
                ],
                const SizedBox(height: 24),
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
                          initialZoom: 14,
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
                                width: 48,
                                height: 48,
                                child: const Icon(
                                  Icons.location_on,
                                  size: 44,
                                  color: Colors.red,
                                ),
                              ),
                              if (request.technicianName != null)
                                Marker(
                                  point: LatLng(
                                    request.latitude! + 0.006,
                                    request.longitude! + 0.006,
                                  ),
                                  width: 48,
                                  height: 48,
                                  child: const Icon(
                                    Icons.build_circle,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
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
