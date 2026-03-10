import 'package:arcon_travel_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes.dart';

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const MainBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.transparent,
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: AppTheme.whiteColor,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? AppTheme.transparent
                    : AppTheme.darkSurfaceColor,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.secondaryColor,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(Icons.history_outlined, Icons.history, 'History'),
              _buildNavItem(
                Icons.article_outlined,
                Icons.article_rounded,
                'Support',
              ),
              _buildNavItem(
                Icons.phone_in_talk_outlined,
                Icons.phone_in_talk,
                'Connect',
              ),
              _buildNavItem(Icons.logout_outlined, Icons.logout, 'Log out'),
            ],
            onTap: (index) => _onItemTapped(context, index),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData iconOutlined,
    IconData iconFilled,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(iconOutlined),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: Icon(iconFilled));
          },
        ),
      ),
      label: label,
    );
  }

  void _onItemTapped(BuildContext context, int index) async {
    if (currentIndex == index) return;

    // Define routes for each tab
    final routes = [
      AppRoutes.home,
      AppRoutes.history,
      AppRoutes.incidentHistory,
      AppRoutes.notifications,
      AppRoutes.login,
    ];

    // Get the route name for the selected index
    final String routeName = routes[index];

    if (routeName == AppRoutes.login) {
      // Show confirmation dialog before signing out
      final bool? shouldSignOut = await SignOutDialog.show(context);

      if (shouldSignOut == true) {
        final authRepository = locator<AuthRepository>();
        authRepository.logout();

        // Navigate to login after confirmation
        AppRoutes.navigateToTab(context, routeName);
      }

      // If user cancels (shouldSignOut is false or null), do nothing
      return;
    }

    // Use the AppRoutes class for navigation with animations
    AppRoutes.navigateToTab(context, routeName);
  }
}

class SignOutDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you need to Log off?',
            style: TextStyle(fontSize: 16, color: AppTheme.primaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false (cancel)
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: AppTheme.primaryColor, width: 1.2),
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true (confirm)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
