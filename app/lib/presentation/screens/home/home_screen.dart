import 'dart:math';
import 'package:arcon_travel_app/presentation/screens/home/on_going_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as date;
import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/models/travel_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/travels_repository.dart';
import '../../../domain/entities/travel_entity.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/main_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  // Repository instances
  final _authRepo = locator<AuthRepository>();
  final _travelRepo = locator<TravelsRepository>();
  List<TravelEntity> _travels = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Set status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _fetchTravelData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchTravelData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final travelData = await _getTravelData();
      setState(() {
        _travels = travelData;
        isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {});
      _showErrorSnackbar(e.toString());
    }
    isLoading = false;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<List<TravelEntity>> _getTravelData() async {
    final user = await _authRepo.getCurrentUser();

    if (user == null) {
      return [];
    }

    final travelList = await _travelRepo.getUserTavelData(user.id);

    return travelList
        .where((travel) => travel.travelStatus == TravelStatus.ON_GOING)
        .map((travel) => TravelEntity.fromModel(travel))
        .toList();
  }

  void _showTripDetails(BuildContext context, TravelEntity tripData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnGoingDetails(travelEntity: tripData),
      ),
    );
    if (result == true) {
      // Refresh your travel list or reload data
      _fetchTravelData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        centerTitle: false,
        title: Text('Ongoing Trips'),

        actions: [
          FadeTransition(
            opacity: _fadeController,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Image.asset('assets/images/acorn_logo.png', height: 32),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildOngoingTrips()),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildOngoingTrips() {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_travels.isEmpty) {
      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: _fadeController,
          child: Center(child: Text('You don\'t have any Ongoing trips')),
        ),
      );
    }

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: _fadeController,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children:
              _travels.map((travel) {
                final data = _createRandomArrivalTimeAndDepatureTime();

                final String depatureTime = data['departureTime']!;
                final String arrivalTime = data['arrivalTime']!;

                return _buildTripCard(
                  tripData: {
                    'origin': travel.startingLocation,
                    'destination': travel.destination,
                    'duration': _createRandomDuration(),
                    'departureTime': travel.travelDate,
                    'arrivalTime': arrivalTime,
                    'transits': _createRandomTransit(),
                    'flightNumber': 'BA016',
                    'aircraft': 'Flydubai FZ 1634',
                    'terminal': 'Terminal 3',
                    'gate': 'Gate B32',
                    'status': 'On Time',
                    'flights': travel.flights,
                    'hotels': travel.hotels,
                  },
                  travelEntity: travel,
                );
              }).toList(),
        ),
      ),
    );
  }

  String _createRandomDuration() {
    final random = Random();

    // Generate random hours between 1 and 15
    final hours = random.nextInt(15) + 1;

    // Generate random minutes (0, 15, 30, 45)
    final minuteOptions = [0, 15, 30, 45];
    final minutes = minuteOptions[random.nextInt(minuteOptions.length)];

    // Format the duration string
    return '${hours}h ${minutes}m';
  }

  Map<String, String> _createRandomArrivalTimeAndDepatureTime() {
    final random = Random();

    // Generate random departure hour (0-23)
    final departureHour = random.nextInt(24);

    // Generate random departure minute (0, 15, 30, 45)
    final minuteOptions = [0, 15, 30, 45];
    final departureMinute = minuteOptions[random.nextInt(minuteOptions.length)];

    // Format departure time in 12-hour format with AM/PM
    final departureHour12 =
        departureHour == 0
            ? 12
            : (departureHour > 12 ? departureHour - 12 : departureHour);
    final departureAmPm = departureHour < 12 ? 'AM' : 'PM';
    final departureTime =
        '${departureHour12.toString().padLeft(2, '0')}:${departureMinute.toString().padLeft(2, '0')} $departureAmPm';

    // Add a random flight duration (1-9 hours)
    final durationHours = random.nextInt(9) + 1;
    final durationMinutes = minuteOptions[random.nextInt(minuteOptions.length)];

    // Calculate arrival time
    final totalMinutes =
        departureHour * 60 +
        departureMinute +
        durationHours * 60 +
        durationMinutes;
    final arrivalHour24 = (totalMinutes ~/ 60) % 24;
    final arrivalMinute = totalMinutes % 60;

    // Format arrival time in 12-hour format with AM/PM
    final arrivalHour12 =
        arrivalHour24 == 0
            ? 12
            : (arrivalHour24 > 12 ? arrivalHour24 - 12 : arrivalHour24);
    final arrivalAmPm = arrivalHour24 < 12 ? 'AM' : 'PM';
    final arrivalTime =
        '${arrivalHour12.toString().padLeft(2, '0')}:${arrivalMinute.toString().padLeft(2, '0')} $arrivalAmPm';

    return {'departureTime': departureTime, 'arrivalTime': arrivalTime};
  }

  /// Creates a random transit description string
  int _createRandomTransit() {
    final random = Random();

    // Decide if there will be any transits (0-2)
    final transitCount = random.nextInt(3);

    if (transitCount == 0) {
      return 0;
    } else {
      // Generate random transit cities
      final transitCities = [
        'Dubai (DXB)',
        'Singapore (SIN)',
        'Frankfurt (FRA)',
        'Amsterdam (AMS)',
        'London (LHR)',
        'Paris (CDG)',
        'Istanbul (IST)',
        'Hong Kong (HKG)',
        'New York (JFK)',
        'Tokyo (NRT)',
      ];

      // Select random cities for transits
      final selectedCities = <String>[];
      for (int i = 0; i < transitCount; i++) {
        final cityIndex = random.nextInt(transitCities.length);
        selectedCities.add(transitCities[cityIndex]);
        transitCities.removeAt(cityIndex); // Ensure no duplicate cities
      }

      // Format the transit string
      return transitCount;
    }
  }

  Widget _buildTripCard({
    required Map<String, dynamic> tripData,
    required TravelEntity travelEntity,
  }) {
    return Hero(
      tag: 'trip-${travelEntity.travelId}-${tripData['flightNumber']}',
      child: Card(
        elevation: 10,
        shadowColor: Colors.black,
        color: AppTheme.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            _showTripDetails(context, travelEntity);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['origin'],
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),

                    Text(
                      tripData['destination'],
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['origin'].toString().length <= 3
                          ? tripData['origin'].toString().toUpperCase()
                          : tripData['origin']
                              .toString()
                              .substring(0, 3)
                              .toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildFlightPath(tripData['transits']),
                    Text(
                      tripData['destination'].toString().length <= 3
                          ? tripData['destination'].toString().toUpperCase()
                          : tripData['destination']
                              .toString()
                              .substring(0, 3)
                              .toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    (tripData['departureTime'] ?? "").toString().isEmpty
                        ? ""
                        : date.DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.parse(tripData['departureTime'])),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlightPath(int transits) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(height: 1.5, color: AppTheme.primaryColor),
                ),
                if (transits > 0)
                  ...List.generate(
                    transits,
                    (index) => Positioned(
                      left: (index + 1) * 50.0,
                      child: SizedBox(width: 8, height: 8),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.flight, color: Colors.white, size: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(height: 1.5, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// class _TripDetailsBottomSheet extends StatelessWidget {
//   final TravelEntity tripData;

//   const _TripDetailsBottomSheet({required this.tripData});

//   @override
//   Widget build(BuildContext context) {
//     return OnGoingDetails(historyId: tripData.id, travelEntity: tripData);
//   }

//   Widget _buildTripHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '${tripData['origin']} → ${tripData['destination']}',
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color:
//                     tripData['status'].toString().contains('Delayed')
//                         ? Colors.orange[100]
//                         : Colors.green[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 tripData['status'],
//                 style: TextStyle(
//                   color:
//                       tripData['status'].toString().contains('Delayed')
//                           ? Colors.orange[800]
//                           : Colors.green[800],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Flight ${tripData['flightNumber']}',
//           style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//         ),
//       ],
//     );
//   }

//   Widget _buildFlightDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Flight Details',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         _buildDetailRow(
//           icon: Icons.flight,
//           title: 'Aircraft',
//           value: tripData['aircraft'],
//         ),
//         _buildDetailRow(
//           icon: Icons.access_time,
//           title: 'Duration',
//           value: tripData['duration'],
//         ),
//         _buildDetailRow(
//           icon: Icons.compare_arrows,
//           title: 'Transits',
//           value: '${tripData['transits']} stops',
//         ),
//       ],
//     );
//   }

//   Widget _buildTravelDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Travel Details',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         _buildDetailRow(
//           icon: Icons.door_front_door,
//           title: 'Terminal',
//           value: tripData['terminal'],
//         ),
//         _buildDetailRow(
//           icon: Icons.door_sliding,
//           title: 'Gate',
//           value: tripData['gate'],
//         ),
//         _buildDetailRow(
//           icon: Icons.schedule,
//           title: 'Boarding',
//           value: '11:50 AM',
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Icon(icon, color: AppTheme.primaryColor, size: 24),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

Widget _buildActionButtons(BuildContext context) {
  return Row(
    // children: [
    //   Expanded(
    //     child: ElevatedButton.icon(
    //       onPressed: () {
    //         // Handle check-in action
    //       },
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: AppTheme.primaryColor,
    //         padding: const EdgeInsets.symmetric(vertical: 16),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //       ),
    //       icon: const Icon(Icons.check_circle_outline),
    //       label: const Text('Check-in', style: TextStyle(fontSize: 16)),
    //     ),
    //   ),
    //   const SizedBox(width: 16),
    //   Expanded(
    //     child: OutlinedButton.icon(
    //       onPressed: () {
    //         // Handle view boarding pass action
    //       },
    //       style: OutlinedButton.styleFrom(
    //         foregroundColor: AppTheme.primaryColor,
    //         side: const BorderSide(color: AppTheme.primaryColor),
    //         padding: const EdgeInsets.symmetric(vertical: 16),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //       ),
    //       icon: const Icon(Icons.airplane_ticket_outlined),
    //       label: const Text('Boarding Pass', style: TextStyle(fontSize: 16)),
    //     ),
    //   ),
    // ],
  );
}
// }

// Add a custom page route for smooth transitions
class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
    : super(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      );
}

// Custom shape for bottom sheet
class BottomSheetShape extends ShapeBorder {
  final double radius;

  const BottomSheetShape({this.radius = 20});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top + radius)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + radius)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
