import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/repair_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/helpers.dart';
import 'chat_room.dart';

class TechnicianJobDetailScreen extends StatefulWidget {
  const TechnicianJobDetailScreen({
    super.key,
    required this.job,
    this.onChanged,
  });

  final RepairRequest job;
  final Future<void> Function()? onChanged;

  @override
  State<TechnicianJobDetailScreen> createState() =>
      _TechnicianJobDetailScreenState();
}

class _TechnicianJobDetailScreenState extends State<TechnicianJobDetailScreen> {
  final _service = FirebaseService();
  late RepairRequest _job = widget.job;
  bool _busy = false;

  bool get _hasLocation => _job.latitude != null && _job.longitude != null;

  bool get _canAccept =>
      _job.status == 'pending' && (_job.technicianId == null || _job.technicianId!.isEmpty);

  bool get _canUpdate =>
      _job.status == 'accepted' || _job.status == 'in_progress';

  @override
  Widget build(BuildContext context) {
    final position = _hasLocation
        ? LatLng(_job.latitude!, _job.longitude!)
        : const LatLng(-1.286389, 36.817223);

    return Scaffold(
      appBar: AppBar(title: Text(_job.applianceName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 230,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _hasLocation
                  ? FlutterMap(
                      options: MapOptions(
                        center: position,
                        zoom: 15,
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
                              point: position,
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
                    )
                  : Container(
                      color: const Color(0xFFEFF4FB),
                      alignment: Alignment.center,
                      child: const Text('No map location was added for this job.'),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.info_outline,
            title: readableStatus(_job.status),
            subtitle: _job.description,
          ),
          _InfoTile(
            icon: Icons.person_outline,
            title: _job.customerName,
            subtitle: [
              if (_job.customerPhone != null && _job.customerPhone!.isNotEmpty)
                _job.customerPhone!,
              if (_job.customerEmail != null && _job.customerEmail!.isNotEmpty)
                _job.customerEmail!,
            ].join('\n'),
          ),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: _job.address,
            subtitle: _hasLocation
                ? '${_job.latitude!.toStringAsFixed(6)}, ${_job.longitude!.toStringAsFixed(6)}'
                : null,
          ),
          _InfoTile(
            icon: Icons.schedule_outlined,
            title: [
              if (_job.preferredDate != null) _job.preferredDate,
              if (_job.preferredTime != null) _job.preferredTime,
            ].whereType<String>().join(' - '),
            subtitle: 'Estimated ${money(_job.estimatedCost ?? 0)}',
          ),
          const SizedBox(height: 10),
          if (_canAccept)
            FilledButton.icon(
              onPressed: _busy ? null : _accept,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accept job'),
            ),
          if (_canUpdate)
            DropdownButtonFormField<String>(
              initialValue: _job.status,
              decoration: const InputDecoration(labelText: 'Update status'),
              items: const [
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: _busy || !_canUpdate
                  ? null
                  : (value) => value == null ? null : _update(value),
            ),
          const SizedBox(height: 10),
          if ((_job.technicianId ?? '').isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    title: _job.customerName,
                    subtitle: _job.applianceName,
                    requestId: _job.id,
                    recipientId: _job.customerId,
                  ),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat with customer'),
            ),
        ],
      ),
    );
  }

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      final technician = context.read<AuthProvider>().user!;
      await _service.acceptJob(_job.id, technician);
      await widget.onChanged?.call();
      if (mounted) showToast(context, 'Job accepted.');
      setState(() {
        _job = RepairRequest(
          id: _job.id,
          customerId: _job.customerId,
          technicianId: technician.id,
          applianceId: _job.applianceId,
          applianceName: _job.applianceName,
          customerName: _job.customerName,
          customerEmail: _job.customerEmail,
          customerPhone: _job.customerPhone,
          technicianName: technician.name,
          description: _job.description,
          preferredDate: _job.preferredDate,
          preferredTime: _job.preferredTime,
          address: _job.address,
          latitude: _job.latitude,
          longitude: _job.longitude,
          status: 'accepted',
          estimatedCost: _job.estimatedCost,
          actualCost: _job.actualCost,
          createdAt: _job.createdAt,
          completedAt: _job.completedAt,
        );
      });
    } on FirebaseServiceException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _update(String status) async {
    if (status == _job.status) return;
    setState(() => _busy = true);
    try {
      await _service.updateJobStatus(_job.id, status);
      await widget.onChanged?.call();
      if (mounted) showToast(context, 'Status updated.');
      setState(() {
        _job = RepairRequest(
          id: _job.id,
          customerId: _job.customerId,
          technicianId: _job.technicianId,
          applianceId: _job.applianceId,
          applianceName: _job.applianceName,
          customerName: _job.customerName,
          customerEmail: _job.customerEmail,
          customerPhone: _job.customerPhone,
          technicianName: _job.technicianName,
          description: _job.description,
          preferredDate: _job.preferredDate,
          preferredTime: _job.preferredTime,
          address: _job.address,
          latitude: _job.latitude,
          longitude: _job.longitude,
          status: status,
          estimatedCost: _job.estimatedCost,
          actualCost: _job.actualCost,
          createdAt: _job.createdAt,
          completedAt: status == 'completed'
              ? DateTime.now().toIso8601String()
              : _job.completedAt,
        );
      });
    } on FirebaseServiceException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title.isEmpty ? '-' : title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
    );
  }
}
