import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/placeholder_tab_view.dart';
import 'home_screen.dart';

/// Main navigation scaffold holding Bottom Navigation Bar with 4 tabs
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    PlaceholderTabView(
      title: 'Appointments',
      description:
          'Schedule and manage appointments with certified veterinary doctors, hospital visits, and video consultations.',
      icon: Icons.calendar_month_rounded,
      nextStepNotice: 'Appointments Feature',
    ),
    PlaceholderTabView(
      title: 'Pet Care Shop',
      description:
          'Order premium nutrition, healthcare supplements, prescription diets, toys, and grooming essentials.',
      icon: Icons.shopping_bag_rounded,
      nextStepNotice: 'Pet Store Feature',
    ),
    PlaceholderTabView(
      title: 'Medical Records',
      description:
          'Access your pets\' electronic health records, vaccination certificates, lab reports, and prescriptions.',
      icon: Icons.assignment_rounded,
      nextStepNotice: 'Health Vault Feature',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Medical Records',
            ),
          ],
        ),
      ),
    );
  }
}
