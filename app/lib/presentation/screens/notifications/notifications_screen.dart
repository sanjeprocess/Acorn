// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../widgets/main_bottom_navigation.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   late List<TravelNotification> _notifications;
//   bool _isLoading = true;
//   bool _hasUnreadNotifications = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   void _loadNotifications() {
//     Future.delayed(const Duration(milliseconds: 1200), () {
//       setState(() {
//         _notifications =
//             getDemoNotifications()
//               ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
//         _isLoading = false;
//         _checkForUnreadNotifications();
//       });
//     });
//   }

//   void _checkForUnreadNotifications() {
//     _hasUnreadNotifications = _notifications.any(
//       (notification) => !notification.isRead,
//     );
//   }

//   void _markAllAsRead() {
//     setState(() {
//       for (var notification in _notifications) {
//         notification.isRead = true;
//       }
//       _hasUnreadNotifications = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('All notifications marked as read'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _markAsRead(TravelNotification notification) {
//     setState(() {
//       notification.isRead = true;
//       _checkForUnreadNotifications();
//     });
//   }

//   void _deleteNotification(TravelNotification notification) {
//     setState(() {
//       _notifications.remove(notification);
//       _checkForUnreadNotifications();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     final bool isLightTheme = theme.brightness == Brightness.light;
//     final Color primaryColor = theme.primaryColor;

//     return Scaffold(
//       bottomNavigationBar: MainBottomNavigation(currentIndex: 3),
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         actions: [
//           if (_hasUnreadNotifications)
//             IconButton(
//               icon: const Icon(Icons.done_all),
//               onPressed: _markAllAsRead,
//               tooltip: 'Mark all as read',
//             ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 _isLoading = true;
//               });
//               _loadNotifications();
//             },
//             tooltip: 'Refresh',
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Image.asset('assets/images/acorn_logo.png', height: 32),
//           ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? _buildLoadingState()
//               : _notifications.isEmpty
//               ? _buildEmptyState()
//               : _buildNotificationsList(isLightTheme, primaryColor),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(child: CircularProgressIndicator());
//   }

//   Widget _buildEmptyState() {
//     return AnimationConfiguration.synchronized(
//       duration: const Duration(milliseconds: 500),
//       child: SlideAnimation(
//         verticalOffset: 50.0,
//         child: FadeInAnimation(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.notifications_off_outlined,
//                   size: 64,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'No Notifications',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'You don\'t have any notifications yet.',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _isLoading = true;
//                     });
//                     _loadNotifications();
//                   },
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Refresh'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationsList(bool isLightTheme, Color primaryColor) {
//     final Map<String, List<TravelNotification>> groupedNotifications = {};

//     for (var notification in _notifications) {
//       final String date = _formatDate(notification.timestamp);
//       if (!groupedNotifications.containsKey(date)) {
//         groupedNotifications[date] = [];
//       }
//       groupedNotifications[date]!.add(notification);
//     }

//     final List<String> sortedDates =
//         groupedNotifications.keys.toList()..sort((a, b) {
//           final aDate = _parseDateString(a);
//           final bDate = _parseDateString(b);
//           return bDate.compareTo(aDate);
//         });

//     return RefreshIndicator(
//       onRefresh: () async {
//         _loadNotifications();
//         return Future.value();
//       },
//       child: AnimationLimiter(
//         child: ListView.builder(
//           padding: const EdgeInsets.only(top: 8, bottom: 24),
//           itemCount: sortedDates.length,
//           itemBuilder: (context, dateIndex) {
//             final date = sortedDates[dateIndex];
//             final notificationsForDate =
//                 groupedNotifications[date]!
//                   ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

//             return AnimationConfiguration.staggeredList(
//               position: dateIndex,
//               duration: const Duration(milliseconds: 375),
//               child: SlideAnimation(
//                 verticalOffset: 50.0,
//                 child: FadeInAnimation(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(
//                           left: 16,
//                           right: 16,
//                           top: 16,
//                           bottom: 8,
//                         ),
//                         child: Text(
//                           date,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color:
//                                 isLightTheme ? Colors.black54 : Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       ListView.separated(
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: notificationsForDate.length,
//                         separatorBuilder:
//                             (context, index) => const SizedBox(height: 8),
//                         itemBuilder:
//                             (context, index) =>
//                                 AnimationConfiguration.staggeredList(
//                                   position: index,
//                                   duration: const Duration(milliseconds: 375),
//                                   child: SlideAnimation(
//                                     horizontalOffset: 50.0,
//                                     child: FadeInAnimation(
//                                       child: _buildNotificationCard(
//                                         notificationsForDate[index],
//                                         isLightTheme,
//                                         primaryColor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                       ),
//                       if (dateIndex < sortedDates.length - 1)
//                         const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationCard(
//     TravelNotification notification,
//     bool isLightTheme,
//     Color primaryColor,
//   ) {
//     IconData icon;
//     Color iconColor;

//     switch (notification.type) {
//       case NotificationType.alert:
//         icon = Icons.warning_rounded;
//         iconColor = Colors.orange;
//         break;
//       case NotificationType.travelUpdate:
//         icon = Icons.flight;
//         iconColor = Colors.blue;
//         break;
//       case NotificationType.incidentUpdate:
//         icon = Icons.report_problem_outlined;
//         iconColor = Colors.red;
//         break;
//       case NotificationType.general:
//         icon = Icons.info_outline;
//         iconColor = primaryColor;
//         break;
//       case NotificationType.promotion:
//         icon = Icons.local_offer_outlined;
//         iconColor = Colors.purple;
//         break;
//     }

//     final String time = DateFormat('h:mm a').format(notification.timestamp);

//     return Dismissible(
//       key: Key(notification.id),
//       background: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         decoration: BoxDecoration(
//           color: Colors.red,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 16),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (direction) {
//         _deleteNotification(notification);
//       },
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: notification.isRead ? 1 : 2,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () {
//             if (!notification.isRead) {
//               _markAsRead(notification);
//             }
//             _showNotificationDetails(notification);
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: iconColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(icon, color: iconColor),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             notification.title,
//                             style: TextStyle(
//                               fontWeight:
//                                   notification.isRead
//                                       ? FontWeight.normal
//                                       : FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             time,
//                             style: TextStyle(
//                               color:
//                                   isLightTheme
//                                       ? Colors.black54
//                                       : Colors.white54,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     if (!notification.isRead)
//                       Container(
//                         width: 12,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: primaryColor,
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   notification.message,
//                   style: TextStyle(
//                     color: isLightTheme ? Colors.black87 : Colors.white70,
//                     fontSize: 14,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showNotificationDetails(TravelNotification notification) {
//     final ThemeData theme = Theme.of(context);
//     final bool isLightTheme = theme.brightness == Brightness.light;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.6,
//           minChildSize: 0.4,
//           maxChildSize: 0.9,
//           builder: (context, scrollController) {
//             final String dateTime = DateFormat(
//               'MMMM d, yyyy \'at\' h:mm a',
//             ).format(notification.timestamp);

//             return Container(
//               decoration: BoxDecoration(
//                 color: theme.scaffoldBackgroundColor,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 4,
//                     margin: const EdgeInsets.only(top: 8, bottom: 16),
//                     decoration: BoxDecoration(
//                       color: isLightTheme ? Colors.grey[300] : Colors.grey[700],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Expanded(
//                     child: ListView(
//                       controller: scrollController,
//                       padding: const EdgeInsets.all(20),
//                       children: [
//                         Text(
//                           notification.title,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           dateTime,
//                           style: TextStyle(
//                             color:
//                                 isLightTheme ? Colors.black54 : Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           notification.fullMessage ?? notification.message,
//                           style: const TextStyle(fontSize: 16, height: 1.5),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   DateTime _parseDateString(String dateStr) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);

//     switch (dateStr) {
//       case 'Today':
//         return today;
//       case 'Yesterday':
//         return today.subtract(const Duration(days: 1));
//       default:
//         try {
//           final DateFormat dayFormat = DateFormat('EEEE');
//           for (int i = 0; i < 7; i++) {
//             final date = today.subtract(Duration(days: i));
//             if (dayFormat.format(date) == dateStr) {
//               return date;
//             }
//           }
//         } catch (_) {}

//         try {
//           return DateFormat('MMMM d, yyyy').parse(dateStr);
//         } catch (_) {
//           return DateTime(1900);
//         }
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final dateToCheck = DateTime(date.year, date.month, date.day);

//     if (dateToCheck == today) {
//       return 'Today';
//     } else if (dateToCheck == yesterday) {
//       return 'Yesterday';
//     } else if (dateToCheck.isAfter(today.subtract(const Duration(days: 7)))) {
//       return DateFormat('EEEE').format(date); // Day of week
//     } else {
//       return DateFormat('MMMM d, yyyy').format(date); // Full date
//     }
//   }
// }

// // Notification types
// enum NotificationType {
//   alert,
//   travelUpdate,
//   incidentUpdate,
//   general,
//   promotion,
// }

// // Notification model
// class TravelNotification {
//   final String id;
//   final String title;
//   final String message;
//   final String? fullMessage;
//   final DateTime timestamp;
//   final NotificationType type;
//   bool isRead;

//   TravelNotification({
//     required this.id,
//     required this.title,
//     required this.message,
//     this.fullMessage,
//     required this.timestamp,
//     required this.type,
//     this.isRead = false,
//   });
// }

// // Demo notifications data
// List<TravelNotification> getDemoNotifications() {
//   final now = DateTime.now();

//   return [
//     TravelNotification(
//       id: 'not-001',
//       title: 'Travel Advisory: Barcelona',
//       message:
//           'Public transportation strike planned for tomorrow in Barcelona. Consider alternative transportation options.',
//       fullMessage:
//           '''Public transportation strike planned for tomorrow in Barcelona. The strike is expected to affect all metro lines, buses, and trams from 6:00 AM to 10:00 PM.

// We recommend:
// - Using taxi services or ride-sharing apps
// - Rescheduling non-essential travel
// - Allowing extra time for important journeys

// The strike may cause significant congestion on roads and highways. Stay updated with local news for the latest information.''',
//       timestamp: now.subtract(const Duration(minutes: 30)),
//       type: NotificationType.alert,
//       isRead: false,
//     ),
//     TravelNotification(
//       id: 'not-002',
//       title: 'Flight Status Update',
//       message:
//           'Your flight BA492 to London is on time. Boarding starts in 2 hours at Gate 14.',
//       fullMessage: '''Your flight BA492 to London is currently on schedule.

// Flight Details:
// - Departure: Gate 14
// - Boarding Time: 14:30
// - Flight Duration: 2h 15m
// - Arrival Terminal: Terminal 5

// Please proceed to the gate area at least 30 minutes before boarding time.''',
//       timestamp: now.subtract(const Duration(hours: 3)),
//       type: NotificationType.travelUpdate,
//       isRead: true,
//     ),
//     TravelNotification(
//       id: 'not-003',
//       title: 'Incident Report Update',
//       message:
//           'Your incident report #INC12345678 regarding lost luggage has been updated to "In Progress".',
//       fullMessage:
//           '''Your incident report #INC12345678 regarding lost luggage at Charles de Gaulle Airport has been updated from "Pending" to "In Progress".

// Our support team is actively working with the airline to locate your luggage. We've received confirmation that your luggage has been located and is scheduled for delivery to your hotel within the next 24-48 hours.

// A support representative will contact you with more details shortly.''',
//       timestamp: now.subtract(const Duration(hours: 8)),
//       type: NotificationType.incidentUpdate,
//       isRead: false,
//     ),
//     TravelNotification(
//       id: 'not-004',
//       title: 'Hotel Check-in Available',
//       message:
//           'Early check-in is now available for your stay at Grand Hyatt Tokyo.',
//       fullMessage:
//           '''Good news! Your room at Grand Hyatt Tokyo is ready for early check-in.

// Reservation Details:
// - Check-in: Available now
// - Room Type: Deluxe King
// - Room Number: Will be assigned at check-in
// - Stay Duration: May 15-20

// Please proceed to the front desk with your ID and booking confirmation.''',
//       timestamp: now.subtract(const Duration(days: 1, hours: 4)),
//       type: NotificationType.general,
//       isRead: true,
//     ),
//     TravelNotification(
//       id: 'not-005',
//       title: 'Special Summer Deals',
//       message:
//           'Exclusive summer flight deals to Asia! Save up to 30% when booking through our app.',
//       fullMessage:
//           '''Limited time summer travel deals to popular Asian destinations!

// Featured Deals:
// - Tokyo: from \$699
// - Seoul: from \$649
// - Bangkok: from \$599
// - Singapore: from \$749

// Book by June 30 for travel between July 1 and August 31.
// All prices include taxes and fees.''',
//       timestamp: now.subtract(const Duration(days: 2)),
//       type: NotificationType.promotion,
//       isRead: true,
//     ),
//     TravelNotification(
//       id: 'not-006',
//       title: 'Weather Alert: Rome',
//       message:
//           'Heavy rainfall expected in Rome during your scheduled visit. Consider indoor activities.',
//       fullMessage: '''Weather Alert for Rome, Italy

// Forecast for your stay:
// - Heavy rainfall expected (80% chance)
// - Temperature: 18°C - 22°C
// - Wind: 15-20 km/h

// Recommended indoor activities:
// - Vatican Museums
// - Galleria Borghese
// - Pantheon
// - Shopping at Galleria Alberto Sordi''',
//       timestamp: now.subtract(const Duration(days: 3)),
//       type: NotificationType.alert,
//       isRead: true,
//     ),
//   ];
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/theme.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/main_bottom_navigation.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  final _authRepo = locator.get<AuthRepository>();

  // Contact info
  String _contactPersonName = '';
  String _contactMobileNumber = '';
  String _contactEmail = '';

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  // Load contact information
  Future<void> _loadContactInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserModel? userModel = await _authRepo.getCurrentUser();

      if (userModel != null) {
        final csaData = userModel.csa;

        setState(() {
          _contactEmail = csaData['email'] ?? '';
          _contactMobileNumber = csaData['mobile'] ?? '';
          _contactPersonName = csaData['name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading contact info: $e');
      // Show error message if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Make a phone call with proper error handling
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      await _makeWhatsAppCall(phoneNumber);
      // final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri);
      // } else {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Could not launch phone dialer')),
      //     );
      //   }
      // }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Future<void> _makeWhatsAppCall(String phoneNumber) async {
  //   final Uri callUri = Uri.parse("whatsapp://send?phone=+94$phoneNumber");

  //   if (await canLaunchUrl(callUri)) {
  //     await launchUrl(callUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw "WhatsApp is not installed or cannot make the call.";
  //   }
  // }

  Future<void> _makeWhatsAppCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Try https format first (most reliable)
    final Uri httpsUri = Uri.parse("https://wa.me/94$cleanNumber");
    // Fallback to whatsapp scheme
    final Uri whatsappUri = Uri.parse("whatsapp://send?phone=94$cleanNumber");

    try {
      if (await canLaunchUrl(httpsUri)) {
        await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw "WhatsApp is not installed";
      }
    } catch (e) {
      throw "WhatsApp is not installed";
    }
  }

  // Send an email
  Future<void> _sendEmail(String email) async {
    try {
      final Uri uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {'subject': 'Travel Support Request'},
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Contact Us'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/acorn_logo.png', height: 32),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 3),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Your Personal Travel Assistant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Feel free to reach out whenever you need assistance with your travel arrangements.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile picture and name
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    _contactPersonName.isNotEmpty
                                        ? _contactPersonName[0]
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.whiteColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _contactPersonName.isNotEmpty
                                            ? _contactPersonName
                                            : 'Travel Consultant',
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Customer Support Agent',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 24),

                            // Contact information
                            _buildContactInfo(
                              icon: Icons.phone,
                              title: 'Phone Number',
                              value:
                                  _contactMobileNumber.isNotEmpty
                                      ? _contactMobileNumber
                                      : 'Not available',
                              onTap:
                                  _contactMobileNumber.isNotEmpty
                                      ? () async =>
                                          _makePhoneCall(_contactMobileNumber)
                                      : null,
                            ),

                            const SizedBox(height: 16),

                            // _buildContactInfo(
                            //   icon: Icons.email,
                            //   title: 'Email Address',
                            //   value:
                            //       _contactEmail.isNotEmpty
                            //           ? _contactEmail
                            //           : 'Not available',
                            //   onTap:
                            //       _contactEmail.isNotEmpty
                            //           ? () => _sendEmail(_contactEmail)
                            //           : null,
                            // ),
                            const SizedBox(height: 24),

                            // Call Now button
                            if (_contactMobileNumber.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () async =>
                                          _makePhoneCall(_contactMobileNumber),
                                  icon: const Icon(
                                    Icons.call,
                                    color: AppTheme.whiteColor,
                                  ),
                                  label: const Text('CALL NOW'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: AppTheme.whiteColor,
                                    backgroundColor: AppTheme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Send Email button
                            // if (_contactEmail.isNotEmpty)
                            //   SizedBox(
                            //     width: double.infinity,
                            //     child: OutlinedButton.icon(
                            //       onPressed: () => _sendEmail(_contactEmail),
                            //       icon: const Icon(
                            //         Icons.email_outlined,
                            //         color: AppTheme.whiteColor,
                            //       ),
                            //       label: const Text('SEND EMAIL'),
                            //       style: OutlinedButton.styleFrom(
                            //         foregroundColor: Colors.white,
                            //         side: const BorderSide(color: Colors.white),
                            //         padding: const EdgeInsets.symmetric(
                            //           vertical: 12,
                            //         ),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Support hours information
                  ],
                ),
              ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryColor,
              size: 16,
            ),
        ],
      ),
    );
  }
}
