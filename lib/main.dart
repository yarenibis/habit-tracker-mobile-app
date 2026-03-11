import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_habit_tracker/core/theme/app_theme.dart';
import 'package:pixel_habit_tracker/presentation/pages/home/home_page.dart';
import 'package:pixel_habit_tracker/presentation/pages/progress/progress_page.dart';
import 'package:pixel_habit_tracker/presentation/pages/profile/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ProviderScope(child: PixelHabitApp()));
}

class PixelHabitApp extends StatelessWidget {
  const PixelHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Habits',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.background,
      extendBody: true, // içerik navbar altına uzasın, bg tam kaplar
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          ProgressPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: _PixelBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _PixelBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _PixelBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Color(0xFF5A9FD4), width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                label: 'HOME',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _Divider(),
              _NavItem(
                label: 'PROGRESS',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _Divider(),
              _NavItem(
                label: 'PROFILE',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 2, height: 40, color: const Color(0xFF5A9FD4).withOpacity(0.4));
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final int index, currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: isSelected
              ? const Color(0xFF5A9FD4).withOpacity(0.15)
              : Colors.transparent,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 7,
                letterSpacing: 0.5,
                color: isSelected
                    ? PixelColors.yellow
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
