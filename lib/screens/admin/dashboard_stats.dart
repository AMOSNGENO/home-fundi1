import 'package:flutter/material.dart';

import '../../models/repair_request.dart';
import '../../services/php_api_service.dart';
import '../../widgets/app_widgets.dart';

class DashboardStatsScreen extends StatelessWidget {
  const DashboardStatsScreen({super.key});

  static const _blue = Color(0xFF062A70);
  static const _brightBlue = Color(0xFF1468F2);
  static const _red = Color(0xFFE53B31);
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF5B6472);

  @override
  Widget build(BuildContext context) {
    final service = PhpApiService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<_DashboardData>(
        future: _load(service),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final data = snapshot.data ?? const _DashboardData({}, []);
          final stats = data.stats;
          final requests = data.requests;
          final pending = requests.where((request) => request.status == 'pending').length;
          final active = requests
              .where(
                (request) =>
                    request.status == 'accepted' || request.status == 'in_progress',
              )
              .length;
          final completed = requests.where((request) => request.status == 'completed').length;
          final customers = stats['total_customers'] ?? stats['total_users'] ?? 0;
          final fundis = stats['total_technicians'] ?? 0;
          final revenue = stats['revenue'] ?? 0;

          return RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _AdminHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  sliver: SliverList.list(
                    children: [
                      const _DashboardTitle(),
                      const SizedBox(height: 14),
                      _MetricGrid(
                        cards: [
                          _MetricData(
                            'Total Customers',
                            '$customers',
                            Icons.groups,
                            _brightBlue,
                            '12.5%',
                          ),
                          _MetricData(
                            'Total Fundis',
                            '$fundis',
                            Icons.person,
                            _blue,
                            '8.3%',
                          ),
                          _MetricData(
                            'Active Jobs',
                            '$active',
                            Icons.business_center,
                            _brightBlue,
                            '10.2%',
                          ),
                          _MetricData(
                            'Completed Jobs',
                            '$completed',
                            Icons.check_circle,
                            _blue,
                            '15.8%',
                          ),
                          _MetricData(
                            'Total Revenue',
                            'Ksh $revenue',
                            Icons.savings,
                            _red,
                            '18.6%',
                          ),
                          _MetricData(
                            'Pending Requests',
                            '$pending',
                            Icons.bar_chart,
                            _red,
                            '9.7%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _RevenueCard(revenue: revenue),
                      const SizedBox(height: 12),
                      _CategoryCard(requests: requests),
                      const SizedBox(height: 12),
                      const _QuickActions(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_DashboardData> _load(PhpApiService service) async {
    final results = await Future.wait([
      service.dashboardStats(),
      service.allRequests(),
    ]);
    return _DashboardData(
      results[0] as Map<String, dynamic>,
      results[1] as List<RepairRequest>,
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF062A70), Color(0xFF0B55C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              tooltip: 'Menu',
            ),
            const Expanded(
              child: Text(
                'Home Fundi Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
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

class _DashboardTitle extends StatelessWidget {
  const _DashboardTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Dashboard',
            style: TextStyle(
              color: DashboardStatsScreen._text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          label: const Text('This Month'),
          style: OutlinedButton.styleFrom(
            foregroundColor: DashboardStatsScreen._blue,
            side: const BorderSide(color: Color(0xFFDDE5F3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.cards});

  final List<_MetricData> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 760 ? 2.35 : 1.5,
          ),
          itemBuilder: (context, index) => _MetricCard(data: cards[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(data.icon, color: data.color, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardStatsScreen._text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardStatsScreen._muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'up ${data.change}',
                  style: const TextStyle(
                    color: DashboardStatsScreen._brightBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.revenue});

  final Object revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Revenue Overview',
                  style: TextStyle(
                    color: DashboardStatsScreen._text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                label: const Text('Month'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _RevenueChartPainter(),
              child: Align(
                alignment: const Alignment(0.55, -0.72),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: DashboardStatsScreen._blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Ksh $revenue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE1E7F1)
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[
      Offset(0, size.height * .72),
      Offset(size.width * .12, size.height * .64),
      Offset(size.width * .22, size.height * .58),
      Offset(size.width * .34, size.height * .50),
      Offset(size.width * .45, size.height * .57),
      Offset(size.width * .58, size.height * .42),
      Offset(size.width * .70, size.height * .32),
      Offset(size.width * .82, size.height * .26),
      Offset(size.width, size.height * .16),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = DashboardStatsScreen._brightBlue.withValues(alpha: 0.10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = DashboardStatsScreen._brightBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = DashboardStatsScreen._red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.requests});

  final List<RepairRequest> requests;

  @override
  Widget build(BuildContext context) {
    final total = requests.isEmpty ? 1 : requests.length;
    final plumbing = requests
        .where((request) => request.applianceName.toLowerCase().contains('plumb'))
        .length;
    final electrical = requests
        .where((request) => request.applianceName.toLowerCase().contains('electric'))
        .length;
    final others = total - plumbing - electrical;
    final rows = [
      _CategoryRow('Plumbing', plumbing, total, DashboardStatsScreen._brightBlue),
      _CategoryRow('Electrical', electrical, total, DashboardStatsScreen._red),
      _CategoryRow('Others', others < 0 ? 0 : others, total, const Color(0xFF9AA4B2)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Jobs by Category',
                  style: TextStyle(
                    color: DashboardStatsScreen._text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CustomPaint(
                painter: _DonutPainter(rows: rows),
                child: const SizedBox.square(dimension: 120),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: rows,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(this.label, this.count, this.total, this.color);

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (count / total * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const SizedBox.square(dimension: 10),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: DashboardStatsScreen._muted),
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: DashboardStatsScreen._text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.rows});

  final List<_CategoryRow> rows;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    var start = -90.0;
    final total = rows.fold<int>(0, (sum, row) => sum + row.count);
    for (final row in rows) {
      final sweep = total == 0 ? 120.0 : row.count / total * 360;
      canvas.drawArc(
        rect.deflate(16),
        start * 3.14159 / 180,
        sweep * 3.14159 / 180,
        false,
        Paint()
          ..color = row.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 24
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: DashboardStatsScreen._text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.person_add, label: 'Add Fundi')),
              Expanded(child: _QuickAction(icon: Icons.grid_view, label: 'Add Category')),
              Expanded(child: _QuickAction(icon: Icons.campaign, label: 'Create Ad')),
              Expanded(child: _QuickAction(icon: Icons.support_agent, label: 'Support')),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8F6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(icon, color: DashboardStatsScreen._blue, size: 28),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DashboardStatsScreen._muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
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
        color: DashboardStatsScreen._red,
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

class _MetricData {
  const _MetricData(this.label, this.value, this.icon, this.color, this.change);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
}

class _DashboardData {
  final Map<String, dynamic> stats;
  final List<RepairRequest> requests;

  const _DashboardData(this.stats, this.requests);
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
