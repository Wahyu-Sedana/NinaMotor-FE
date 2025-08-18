import 'package:flutter/material.dart';
import 'package:frontend/features/home/presentations/screens/bookmark_tab.dart';
import 'package:frontend/features/home/presentations/screens/cart_tab.dart';
import 'package:frontend/features/home/presentations/screens/home_tab.dart';
import 'package:frontend/features/profile/presentations/screens/profile_tab.dart';
import 'package:frontend/features/servismotor/presentations/screens/service_motor_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    const HomeTab(),
    const CartTab(),
    const BookmarkTab(),
    const ServiceMotorTab(),
    const ProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  icon: Icons.home_rounded,
                  index: 0,
                  label: 'Home',
                ),
                _buildTabItem(
                  icon: Icons.shopping_cart_rounded,
                  index: 1,
                  label: 'Cart',
                ),
                _buildTabItem(
                  icon: Icons.bookmark_rounded,
                  index: 2,
                  label: 'Bookmark',
                ),
                _buildTabItem(
                  icon: Icons.motorcycle_rounded,
                  index: 3,
                  label: 'Service',
                ),
                _buildTabItem(
                  icon: Icons.person_rounded,
                  index: 4,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? Colors.red : Colors.grey[600],
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.red : Colors.grey[600],
              ),
              child: isSelected ? Text(label) : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
