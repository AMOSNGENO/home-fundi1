import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/repair_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';

class RateTechnicianScreen extends StatefulWidget {
  final RepairRequest request;
  const RateTechnicianScreen({super.key, required this.request});

  @override
  State<RateTechnicianScreen> createState() => _RateTechnicianScreenState();
}

class _RateTechnicianScreenState extends State<RateTechnicianScreen> {
  final _service = PhpApiService();
  int _rating = 5;
  final _review = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Technician')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.request.technicianName ?? 'Technician',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Slider(
            value: _rating.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$_rating',
            onChanged: (value) => setState(() => _rating = value.round()),
          ),
          TextField(
            controller: _review,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Review'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.star),
            label: const Text('Submit rating'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    try {
      final user = context.read<AuthProvider>().user!;
      await _service.addRating(
        request: widget.request,
        customer: user,
        rating: _rating,
        review: _review.text.trim(),
      );
      if (mounted) {
        showToast(context, 'Rating submitted.');
        Navigator.of(context).pop();
      }
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
