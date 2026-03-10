import 'package:arcon_travel_app/domain/entities/travel_entity.dart';
import 'package:flutter/material.dart';

// Import the page transition manager
import 'core/utils/page_transition_manager.dart';

// Import screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/history/history_screen.dart';
import 'presentation/screens/history/history_detail_screen.dart';
import 'presentation/screens/history/feedback_screen.dart';
import 'presentation/screens/incident/incident_report_screen.dart';
import 'presentation/screens/incident/incident_history_screen.dart';
import 'presentation/screens/chatbot/chatbot_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  // Route names as constants
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String history = '/history';
  static const String historyDetail = '/history/detail';
  static const String addFeedback = '/history/feedback';
  static const String incidentReport = '/incident/report';
  static const String incidentHistory = '/incident/history';
  static const String chatbot = '/chatbot';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String logout = '/logout';

  // Current active route for bottom navigation
  static String currentRoute = home;

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';

    // Determine if this is a tab navigation (for proper transition effects)
    final bool isTabNavigation = [
      home,
      history,
      incidentHistory,
      notifications,
    ].contains(routeName);

    // Determine the transition type based on navigation pattern
    PageTransitionType transitionType = PageTransitionType.fade;

    if (isTabNavigation) {
      // If we're navigating between tabs
      final List<String> orderedTabs = [
        home,
        history,
        incidentHistory,
        notifications,
      ];
      final int currentIndex = orderedTabs.indexOf(currentRoute);
      final int targetIndex = orderedTabs.indexOf(routeName);

      if (currentIndex != -1 && targetIndex != -1) {
        transitionType = PageTransitionManager.getTransitionTypeForNavigation(
          currentIndex,
          targetIndex,
        );
      }
    } else if (routeName == login ||
        routeName == signup ||
        routeName == splash) {
      // For authentication flows
      transitionType = PageTransitionType.fade;
    } else if (routeName.contains('detail') || routeName.contains('feedback')) {
      // For detail pages
      transitionType = PageTransitionType.slideLeft;
    } else {
      // Default transition
      transitionType = PageTransitionType.slideUp;
    }

    // Update current route
    if (routeName.isNotEmpty) {
      currentRoute = routeName;
    }

    // Generate routes with appropriate transitions
    switch (settings.name) {
      case splash:
        return PageTransitionManager.createPageRoute(
          page: const SplashScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );

      case login:
        return PageTransitionManager.createPageRoute(
          page: const LoginScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );

      case signup:
        return PageTransitionManager.createPageRoute(
          page: const SignupScreen(),
          type: PageTransitionType.slideLeft,
          settings: settings,
        );

      case forgotPassword:
        return PageTransitionManager.createPageRoute(
          page: const ForgotPasswordScreen(),
          type: PageTransitionType.slideUp,
          settings: settings,
        );

      case home:
        return PageTransitionManager.createPageRoute(
          page: const HomeScreen(),
          type: transitionType,
          settings: settings,
        );

      case history:
        return PageTransitionManager.createPageRoute(
          page: const HistoryScreen(),
          type: transitionType,
          settings: settings,
        );

      case historyDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final historyId = args?['historyId'] as String?;
        final travelEntity = args?['travelEntity'] as TravelEntity;

        return PageTransitionManager.createPageRoute(
          page: HistoryDetailScreen(
            historyId: historyId ?? '',
            travelEntity: travelEntity,
          ),
          type: PageTransitionType.slideLeft,
          settings: settings,
        );

      case addFeedback:
        final args = settings.arguments as Map<String, dynamic>?;
        final historyId = args?['historyId'] as String?;
        final existingFeedback = args?['existingFeedback'] as String?;

        return PageTransitionManager.createPageRoute(
          page: AddFeedbackScreen(
            historyId: historyId ?? '',
            existingFeedback: existingFeedback,
          ),
          type: PageTransitionType.slideUp,
          settings: settings,
        );

      case incidentReport:
        return PageTransitionManager.createPageRoute(
          page: const IncidentReportScreen(),
          type: PageTransitionType.slideUp,
          settings: settings,
        );

      case incidentHistory:
        return PageTransitionManager.createPageRoute(
          page: const IncidentHistoryScreen(),
          type: transitionType,
          settings: settings,
        );

      case chatbot:
        return PageTransitionManager.createPageRoute(
          page: const ChatbotScreen(),
          type: PageTransitionType.scale,
          settings: settings,
        );

      case notifications:
        return PageTransitionManager.createPageRoute(
          page: const NotificationsScreen(),
          type: transitionType,
          settings: settings,
        );

      case profile:
        return PageTransitionManager.createPageRoute(
          page: const ProfileScreen(),
          type: PageTransitionType.slideLeft,
          settings: settings,
        );

      default:
        // Return an error page for undefined routes
        return PageTransitionManager.createPageRoute(
          page: Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found!')),
          ),
          type: PageTransitionType.fade,
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static Future<void> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  // For bottom navigation
  static void navigateToTab(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushReplacement(
        context,
        generateRoute(RouteSettings(name: routeName)),
      );
    }
  }
}

// RoutingObserver to track navigation for analytics purposes
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      // Log route navigation for analytics
      final routeName = route.settings.name;
      debugPrint('New route pushed: $routeName');

      // Here you could trigger analytics events
      // Example: FirebaseAnalytics.instance.logScreenView(screenName: routeName);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      // Log route navigation for analytics
      final routeName = previousRoute.settings.name;
      debugPrint('Returned to route: $routeName');

      // Here you could trigger analytics events
      // Example: FirebaseAnalytics.instance.logScreenView(screenName: routeName);
    }
  }
}
