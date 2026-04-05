import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'home_screen.dart';
import 'workouts_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = const [
      HomeScreen(),
      WorkoutsScreen(),
      _PlaceholderScreen(label: 'PROGRESS', icon: Icons.bar_chart_rounded),
      _PlaceholderScreen(label: 'GOALS', icon: Icons.flag_rounded),
    ];
  }

  static const _navItems = [
    (icon: Icons.speed_rounded,           label: 'DASHBOARD'),
    (icon: Icons.fitness_center_rounded,  label: 'WORKOUT'),
    (icon: Icons.bar_chart_rounded,       label: 'PROGRESS'),
    (icon: Icons.flag_rounded,            label: 'GOALS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final List<({IconData icon, String label})> items;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: const Color(0xFF0F0F00).withOpacity(0.70),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final active = currentIndex == i;
                  return GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: active ? 20 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            items[i].icon,
                            size: 20,
                            color: active
                                ? AppColors.onPrimaryContainer
                                : AppColors.onSurface.withOpacity(0.45),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: active
                                  ? AppColors.onPrimaryContainer
                                  : AppColors.onSurface.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PlaceholderScreen({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 20),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryContainer,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
