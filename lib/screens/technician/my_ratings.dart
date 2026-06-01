import 'package:flutter/material.dart';

import '../../models/rating.dart';
import '../../services/api_service.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  double _average = 0;
  List<RatingReview> _ratings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.get('my_ratings.php');
    setState(() {
      _average = double.tryParse('${data['average'] ?? 0}') ?? 0;
      _ratings = (data['ratings'] as List)
          .map((item) => RatingReview.fromJson(item))
          .toList();
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
