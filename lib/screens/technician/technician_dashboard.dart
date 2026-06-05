import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rating.dart';
import '../../models/repair_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/php_api_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() =>
      _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  static const _blue = Color(0xFF062A70);
  static const _brightBlue = Color(0xFF1468F2);
  static const _red = Color(0xFFFF2E2E);
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF5B6472);

  final _service = PhpApiService();

  Future<_TechnicianDashboardData>? _future;

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  void _reload() {
    final user = context.read<AuthProvider>().user!;
    setState(() {
      _future = _load(user.id);
    });
  }

  Future<_TechnicianDashboardData> _load(String technicianId) async {
    final results = await Future.wait([
      _service.availableJobs(),
      _service.technicianJobs(technicianId),
      _service.technicianRatings(technicianId),
    ]);
    return _TechnicianDashboardData(
      availableJobs: results[0] as List<RepairRequest>,
      myJobs: results[1] as List<RepairRequest>,
      ratings: results[2] as List<RatingReview>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<_TechnicianDashboardData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const _TechnicianDashboardData();
          final myJobs = data.myJobs;
          final active = myJobs
              .where((job) => job.status == 'accepted' || job.status == 'in_progress')
              .length;
          final completed = myJobs.where((job) => job.status == 'completed').length;
          final earnings = myJobs
              .where((job) => job.status == 'completed')
              .fold<double>(
                0,
                (total, job) =>
                    total + (double.tryParse(job.actualCost ?? '0') ?? 0),
              );
          final rating = data.ratings.isEmpty
              ? 0
              : data.ratings
                    .map((rating) => rating.rating)
                    .reduce((a, b) => a + b) /
                    data.ratings.length;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    name: user.name,
                    available: user.isAvailable,
                    onAvailabilityChanged: (value) async {
                      await _service.updateAvailability(user.id, value);
                      await auth.loadSession();
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: _StatsPanel(
                            available: data.availableJobs.length,
                            pending: active,
                            completed: completed,
                            rating: rating.toDouble(),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: const Offset(0, -34),
                          child: _EarningsBanner(earnings: earnings),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: _JobsSection(
                            loading: snapshot.connectionState ==
                                ConnectionState.waiting,
                            jobs: data.availableJobs.take(3).toList(),
                            onAccept: _accept,
                            onReject: _reject,
                          ),
                        ),
                        const Divider(height: 26),
                        _TodayEarnings(earnings: earnings),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _accept(RepairRequest job) async {
    try {
      final technician = context.read<AuthProvider>().user!;
      await _service.acceptJob(job.id, technician);
      _reload();
      if (mounted) showToast(context, 'Job accepted.');
    } on PhpApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }

  void _reject(RepairRequest job) {
    showToast(context, '${job.applianceName} hidden from your dashboard.');
    _reload();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.available,
    required this.onAvailabilityChanged,
  });

  final String name;
  final bool available;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final firstName = name.trim().isEmpty ? 'Fundi' : name.trim().split(' ').first;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF052765), Color(0xFF073A91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 39,
                backgroundColor: Color(0xFFEAF1FF),
                child: Icon(Icons.engineering, color: Color(0xFF062A70), size: 44),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => onAvailabilityChanged(!available),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: available
                                    ? const Color(0xFF1468F2)
                                    : const Color(0xFFFF2E2E),
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox.square(dimension: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              available ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const NotificationBellButton(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.available,
    required this.pending,
    required this.completed,
    required this.rating,
  });

  final int available;
  final int pending;
  final int completed;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: _panelDecoration,
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.business_center,
              iconColor: const Color(0xFF1468F2),
              value: '$available',
              label: 'Available\nJobs',
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.receipt_long,
              iconColor: const Color(0xFFFFB42E),
              value: '$pending',
              label: 'Pending\nJobs',
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.verified,
              iconColor: const Color(0xFF1468F2),
              value: '$completed',
              label: 'Completed\nJobs',
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.star,
              iconColor: const Color(0xFF5946D9),
              value: rating == 0 ? '0.0' : rating.toStringAsFixed(1),
              label: 'Rating',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            color: _TechnicianDashboardScreenState._text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _TechnicianDashboardScreenState._muted,
            fontSize: 12,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _EarningsBanner extends StatelessWidget {
  const _EarningsBanner({required this.earnings});

  final double earnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062A70), Color(0xFF0646A9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete more jobs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'and earn more',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Ksh ${earnings.toStringAsFixed(0)}'),
                ),
              ],
            ),
          ),
          const Icon(Icons.account_balance_wallet, color: Color(0xFFE53B31), size: 82),
        ],
      ),
    );
  }
}

class _JobsSection extends StatelessWidget {
  const _JobsSection({
    required this.loading,
    required this.jobs,
    required this.onAccept,
    required this.onReject,
  });

  final bool loading;
  final List<RepairRequest> jobs;
  final ValueChanged<RepairRequest> onAccept;
  final ValueChanged<RepairRequest> onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'New Job Requests',
                style: TextStyle(
                  color: _TechnicianDashboardScreenState._text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View all')),
          ],
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (jobs.isEmpty)
          const _EmptyJobsCard()
        else
          for (final job in jobs)
            _JobCard(
              job: job,
              onAccept: () => onAccept(job),
              onReject: () => onReject(job),
            ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onAccept,
    required this.onReject,
  });

  final RepairRequest job;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final price = job.estimatedCost ?? job.actualCost ?? '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(_jobIcon(job.applianceName), color: _TechnicianDashboardScreenState._blue, size: 42),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.applianceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _TechnicianDashboardScreenState._text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: _TechnicianDashboardScreenState._brightBlue, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job.address.isEmpty ? 'Customer location' : job.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _TechnicianDashboardScreenState._muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ksh $price',
                  style: const TextStyle(
                    color: _TechnicianDashboardScreenState._brightBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Nearby job request',
                  style: TextStyle(color: _TechnicianDashboardScreenState._muted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _TechnicianDashboardScreenState._red,
                          side: const BorderSide(color: _TechnicianDashboardScreenState._red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: _TechnicianDashboardScreenState._brightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyJobsCard extends StatelessWidget {
  const _EmptyJobsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration,
      child: const Row(
        children: [
          Icon(Icons.work_outline, color: _TechnicianDashboardScreenState._blue),
          SizedBox(width: 12),
          Expanded(child: Text('No new job requests right now.')),
        ],
      ),
    );
  }
}

class _TodayEarnings extends StatelessWidget {
  const _TodayEarnings({required this.earnings});

  final double earnings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Today's Earnings",
            style: TextStyle(
              color: _TechnicianDashboardScreenState._text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          'Ksh ${earnings.toStringAsFixed(0)}',
          style: const TextStyle(
            color: _TechnicianDashboardScreenState._brightBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _TechnicianDashboardScreenState._red,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TechnicianDashboardData {
  const _TechnicianDashboardData({
    this.availableJobs = const [],
    this.myJobs = const [],
    this.ratings = const [],
  });

  final List<RepairRequest> availableJobs;
  final List<RepairRequest> myJobs;
  final List<RatingReview> ratings;
}

IconData _jobIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('electric')) return Icons.lightbulb_outline;
  if (lower.contains('sink')) return Icons.wash;
  if (lower.contains('plumb') || lower.contains('bomba')) return Icons.plumbing;
  if (lower.contains('fridge') || lower.contains('friji')) return Icons.kitchen;
  return Icons.home_repair_service;
}

const _panelDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  boxShadow: [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ],
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFE8ECF4))),
);
