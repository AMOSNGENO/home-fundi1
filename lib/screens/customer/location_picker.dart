import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const _googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
);

class PickedLocation {
  final LatLng point;
  final String address;

  const PickedLocation({required this.point, required this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _search = TextEditingController();
  late LatLng _selected;
  String _address = '';
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation ?? const LatLng(-1.286389, 36.817223);
    _address = widget.initialAddress ?? '';
    if (_address.isEmpty) {
      _resolveAddress(_selected);
    } else {
      _search.text = _address;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check),
            label: const Text('Use'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selected,
              zoom: 15,
            ),
            mapType: MapType.hybrid,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selected,
                draggable: true,
                onDragEnd: _selectPoint,
              ),
            },
            onTap: _selectPoint,
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search location name or address',
                        ),
                        onSubmitted: _searchAddress,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => _searchAddress(_search.text),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_locationLabel),
                    ),
                    FilledButton(
                      onPressed: _confirm,
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _locationLabel {
    if (_resolving) return 'Finding location name...';
    if (_address.trim().isNotEmpty) return _address;
    return '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}';
  }

  void _selectPoint(LatLng point) {
    setState(() => _selected = point);
    _resolveAddress(point);
  }

  Future<void> _searchAddress(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() => _resolving = true);
    try {
      final result = await _googleGeocode(address: query);
      if (result == null || !mounted) {
        _showLocationError();
        return;
      }
      setState(() {
        _selected = result.point;
        _address = result.address;
        _search.text = result.address;
      });
    } catch (_) {
      if (mounted) _showLocationError();
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _resolving = true);
    try {
      final result = await _googleGeocode(point: point);
      if (result == null || !mounted) return;
      setState(() {
        _address = result.address;
        _search.text = result.address;
      });
    } catch (_) {
      if (mounted && _address.isEmpty) {
        setState(() {
          _address =
              '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        });
      }
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<PickedLocation?> _googleGeocode({
    String? address,
    LatLng? point,
  }) async {
    if (_googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') return null;
    final queryParameters = <String, String>{
      'key': _googleMapsApiKey,
      if (address != null && address.isNotEmpty) 'address': address,
      if (point != null) 'latlng': '${point.latitude},${point.longitude}',
    };
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      queryParameters,
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;
    final first = results.first as Map<String, dynamic>;
    final geometry = first['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final latitude = (location?['lat'] as num?)?.toDouble();
    final longitude = (location?['lng'] as num?)?.toDouble();
    final formattedAddress = first['formatted_address']?.toString();
    if (latitude == null || longitude == null || formattedAddress == null) {
      return null;
    }
    return PickedLocation(
      point: LatLng(latitude, longitude),
      address: formattedAddress,
    );
  }

  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location was not found.')),
    );
  }

  void _confirm() {
    Navigator.of(context).pop(
      PickedLocation(point: _selected, address: _locationLabel),
    );
  }
}
