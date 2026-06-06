import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/appliance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import 'location_picker.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _service = PhpApiService();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _quote = TextEditingController();
  final _time = TextEditingController(text: 'Morning');
  final _picker = ImagePicker();
  DateTime? _date;
  Appliance? _appliance;
  LatLng? _location;
  String? _locationName;
  Uint8List? _productImageBytes;
  String? _productImageName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RequestProvider>().loadAppliances());
  }

  @override
  void dispose() {
    _description.dispose();
    _address.dispose();
    _quote.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final error = context.read<RequestProvider>().errorMessage;
        if (error == null) return;
        showToast(context, error, error: true);
        context.read<RequestProvider>().clearError();
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Request Repair')),
      body: RefreshIndicator(
        onRefresh: provider.loadAppliances,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<Appliance>(
              initialValue: _appliance,
              isExpanded: true,
              items: provider.appliances
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.name),
                    ),
                  )
                  .toList(),
              onChanged: provider.appliances.isEmpty
                  ? null
                  : (value) => setState(() => _appliance = value),
              decoration: InputDecoration(
                labelText: provider.loading ? 'Loading appliances' : 'Appliance',
                prefixIcon: const Icon(Icons.kitchen_outlined),
                suffixIcon: provider.loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Describe the issue', prefixIcon: Icon(Icons.description_outlined))),
            const SizedBox(height: 12),
            TextField(
              controller: _quote,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quoted price',
                prefixIcon: Icon(Icons.payments_outlined),
                prefixText: 'KES ',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickProductPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _productImageBytes == null
                    ? 'Share product photo'
                    : _productImageName ?? 'Product photo selected',
              ),
            ),
            if (_productImageBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _productImageBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Repair address', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.satellite_alt_outlined),
              label: Text(
                _location == null
                    ? 'Pick location on satellite map'
                    : _locationName ??
                          '${_location!.latitude.toStringAsFixed(6)}, ${_location!.longitude.toStringAsFixed(6)}',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event), label: Text(_date == null ? 'Preferred date' : _date!.toIso8601String().substring(0, 10)))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _time, decoration: const InputDecoration(labelText: 'Preferred time'))),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              label: const Text('Submit request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickLocation() async {
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: _location,
          initialAddress: _locationName,
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _location = picked.point;
        _locationName = picked.address;
        if (_address.text.trim().isEmpty) {
          _address.text = picked.address;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_appliance == null || _description.text.trim().isEmpty || _address.text.trim().isEmpty) {
      showToast(context, 'Select appliance and complete request details.', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final user = context.read<AuthProvider>().user!;
      await _service.createRepairRequest(
        customer: user,
        appliance: _appliance!,
        description: _description.text.trim(),
        address: _address.text.trim(),
        preferredDate: _date?.toIso8601String().substring(0, 10),
        preferredTime: _time.text.trim(),
        latitude: _location?.latitude,
        longitude: _location?.longitude,
        estimatedCost: _quote.text,
        requestImageData: _productImageBytes == null
            ? null
            : base64Encode(_productImageBytes!),
        requestImageName: _productImageName,
      );
      if (mounted) showToast(context, 'Repair request submitted.');
      _description.clear();
      _address.clear();
      _quote.clear();
      setState(() {
        _location = null;
        _locationName = null;
        _productImageBytes = null;
        _productImageName = null;
      });
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickProductPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _productImageBytes = bytes;
      _productImageName = image.name;
    });
  }
}
