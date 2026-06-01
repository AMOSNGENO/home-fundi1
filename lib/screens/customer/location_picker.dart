import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation ?? const LatLng(-1.286389, 36.817223);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(_selected),
            icon: const Icon(Icons.check),
            label: const Text('Use'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: 13,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tricomtechnologies.home_fundi',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selected,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      size: 44,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
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
                      child: Text(
                        '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}',
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
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
}
