import 'package:flutter/material.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/features/home/presentations/screens/cart_tab.dart';
import 'package:frontend/features/home/presentations/screens/home_tab.dart';
import 'package:frontend/features/profile/presentations/screens/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final _pages = [
    const CartTab(),
    const Center(child: Text("Bookmark")),
    const HomeTab(),
    const Center(child: Text("Service Motor")),
    const ProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabTapped() {
    setState(() {
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTapped,
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.home,
          size: 30,
          color: white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(icon: Icons.shopping_cart, index: 0, label: 'Cart'),
              _buildTabItem(icon: Icons.bookmark, index: 1, label: 'Bookmark'),
              const SizedBox(width: 20),
              _buildTabItem(icon: Icons.motorcycle, index: 3, label: 'Service'),
              _buildTabItem(icon: Icons.person, index: 4, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      {required IconData icon, required int index, required String label}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.red : Colors.grey),
        ],
      ),
    );
  }
}
