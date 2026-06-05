import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_widgets.dart';
import 'post_request.dart';

class FindTechniciansScreen extends StatelessWidget {
  const FindTechniciansScreen({super.key});

  static const _navy = Color(0xFF070C70);
  static const _accent = Color(0xFFE53B31);
  static const _iconBlue = Color(0xFF174B78);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 680 ? 5 : 4;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _categories.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.84,
                              ),
                          itemBuilder: (context, index) {
                            return _CategoryTile(category: _categories[index]);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const _PromoBanner(),
                    const SizedBox(height: 12),
                    const _CarouselDots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Find Technicians',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.navyBlue,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          const NotificationBellButton(),
          IconButton(
            tooltip: 'Search',
            color: AppColors.navyBlue,
            iconSize: 28,
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Filter',
            color: AppColors.navyBlue,
            iconSize: 26,
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final _TechnicianCategory category;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PostRequestScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      category.icon,
                      color: FindTechniciansScreen._iconBlue,
                      size: 36,
                    ),
                    if (category.badgeIcon != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          category.badgeIcon,
                          color: FindTechniciansScreen._accent,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 11),
              Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 13,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: FindTechniciansScreen._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -32,
            bottom: -32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFB9D8E7),
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(120),
              ),
              child: const SizedBox(width: 92),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  children: [
                    TextSpan(
                      text: 'Fundi',
                      style: TextStyle(color: Color(0xFFFF7F42)),
                    ),
                    TextSpan(
                      text: 'Smart Pro',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Onyesha picha zako za kazi, pata wateja kirahisi.\nJenga rating na uaminifu.\nOngeza nafasi ya kupata kazi zaidi.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: true),
        SizedBox(width: 8),
        _Dot(active: false),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active
            ? FindTechniciansScreen._navy
            : const Color(0xFFE1E1E1),
        shape: BoxShape.circle,
      ),
      child: const SizedBox.square(dimension: 9),
    );
  }
}

class _TechnicianCategory {
  const _TechnicianCategory(
    this.label,
    this.icon, {
    this.badgeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? badgeIcon;
}

const _categories = [
  _TechnicianCategory(
    'All Technicians',
    Icons.home_repair_service,
    badgeIcon: Icons.build,
  ),
  _TechnicianCategory(
    'Ujenzi (Masonry)',
    Icons.engineering,
    badgeIcon: Icons.foundation,
  ),
  _TechnicianCategory(
    'Umeme (Majumbani)',
    Icons.electrical_services,
    badgeIcon: Icons.flash_on,
  ),
  _TechnicianCategory(
    'Bomba (Plumbing)',
    Icons.plumbing,
    badgeIcon: Icons.build,
  ),
  _TechnicianCategory(
    'Kushona (Tailoring)',
    Icons.checkroom,
    badgeIcon: Icons.edit,
  ),
  _TechnicianCategory(
    'Rangi na Gipisani',
    Icons.format_paint,
    badgeIcon: Icons.brush,
  ),
  _TechnicianCategory(
    'Makenika (Magari)',
    Icons.miscellaneous_services,
    badgeIcon: Icons.settings,
  ),
  _TechnicianCategory(
    'Umeme (Magari)',
    Icons.car_repair,
    badgeIcon: Icons.flash_on,
  ),
  _TechnicianCategory(
    'Rangi (Magari)',
    Icons.format_color_fill,
    badgeIcon: Icons.chevron_right,
  ),
  _TechnicianCategory(
    'Kuchomelea (Welding)',
    Icons.construction,
    badgeIcon: Icons.local_fire_department,
  ),
  _TechnicianCategory('Kupaua', Icons.roofing, badgeIcon: Icons.handyman),
  _TechnicianCategory(
    'Pikipiki na Bajaj',
    Icons.two_wheeler,
    badgeIcon: Icons.settings,
  ),
  _TechnicianCategory(
    'Electronics (TV/Radio)',
    Icons.tv,
    badgeIcon: Icons.phone_iphone,
  ),
  _TechnicianCategory(
    'Marumaru (Tiles)',
    Icons.grid_view,
    badgeIcon: Icons.brush,
  ),
  _TechnicianCategory(
    "Ving'amuzi",
    Icons.satellite_alt,
    badgeIcon: Icons.wifi,
  ),
  _TechnicianCategory(
    'Uchoraji (Signs & Art)',
    Icons.palette,
    badgeIcon: Icons.brush,
  ),
  _TechnicianCategory(
    'Simu (Phone repair)',
    Icons.phone_android,
    badgeIcon: Icons.build,
  ),
  _TechnicianCategory(
    'Seremala (Carpentry)',
    Icons.handyman,
    badgeIcon: Icons.square,
  ),
  _TechnicianCategory('Friji na A/C', Icons.kitchen, badgeIcon: Icons.air),
  _TechnicianCategory('Aluminum', Icons.window, badgeIcon: Icons.straighten),
];
