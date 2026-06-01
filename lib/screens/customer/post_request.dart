import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import 'location_picker.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _time = TextEditingController(text: 'Morning');
  DateTime? _date;
  int? _applianceId;
  LatLng? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RequestProvider>().loadAppliances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Request Repair')),
      body: RefreshIndicator(
        onRefresh: provider.loadAppliances,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<int>(
              initialValue: _applianceId,
              items: provider.appliances
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item.id, child: Text(item.name)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _applianceId = value),
              decoration: const InputDecoration(
                labelText: 'Appliance',
                prefixIcon: Icon(Icons.kitchen_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe the issue',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Repair address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map_outlined),
              label: Text(
                _location == null
                    ? 'Pick location on map'
                    : '${_location!.latitude.toStringAsFixed(5)}, ${_location!.longitude.toStringAsFixed(5)}',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _date == null
                          ? 'Preferred date'
                          : _date!.toIso8601String().substring(0, 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _time,
                    decoration: const InputDecoration(
                      labelText: 'Preferred time',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Submit request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickLocation() async {
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: _location),
      ),
    );
    if (location != null) {
      setState(() {
        _location = location;
        if (_address.text.trim().isEmpty) {
          _address.text =
              'Pinned location: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_applianceId == null) {
      showToast(context, 'Select the appliance to repair.', error: true);
      return;
    }
    if (_description.text.trim().isEmpty) {
      showToast(context, 'Describe the issue before submitting.', error: true);
      return;
    }
    if (_address.text.trim().isEmpty) {
      showToast(
        context,
        'Enter an address or pick a location on the map.',
        error: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) {
        showToast(
          context,
          'Please login before submitting a request.',
          error: true,
        );
        return;
      }
      final result = await ApiService.post('repair_request.php', {
        'customer_id': user.id,
        'appliance_id': _applianceId,
        'description': _description.text.trim(),
        'preferred_date': _date?.toIso8601String().substring(0, 10),
        'preferred_time': _time.text.trim(),
        'address': _address.text.trim(),
        'latitude': _location?.latitude,
        'longitude': _location?.longitude,
      });
      final assigned = result['assigned_technician'];
      if (mounted) {
        showToast(
          context,
          assigned == null
              ? 'Request submitted. Waiting for a technician.'
              : 'Request submitted. ${assigned['name']} has been assigned.',
        );
      }
      _description.clear();
      _address.clear();
      setState(() => _location = null);
    } on ApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
