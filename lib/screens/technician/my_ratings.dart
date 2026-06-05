import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rating.dart';
import '../../providers/auth_provider.dart';
import '../../services/php_api_service.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final _service = PhpApiService();
  double _average = 0;
  List<RatingReview> _ratings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final technicianId = context.read<AuthProvider>().user!.id;
    final ratings = await _service.technicianRatings(technicianId);
    setState(() {
      _ratings = ratings;
      _average = _ratings.isEmpty
          ? 0
          : _ratings.fold<int>(0, (sum, item) => sum + item.rating) /
                _ratings.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(
                  _average.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text('${_ratings.length} reviews'),
              ),
            ),
            for (final rating in _ratings)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${rating.rating}')),
                  title: Text(rating.customerName),
                  subtitle: Text(rating.review ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
