import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:arcon_travel_app/core/di/dependency_injection.dart';
import 'package:arcon_travel_app/data/models/travel_model.dart';
import 'package:arcon_travel_app/data/repositories/auth_repository.dart';
import 'package:arcon_travel_app/data/repositories/travels_repository.dart';
import 'package:arcon_travel_app/domain/entities/travel_entity.dart';
import '../../../core/theme.dart';
import '../../../routes.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/main_bottom_navigation.dart';
import '../../widgets/flight_info_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/trip_search_delegate.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _listController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Repository instances
  final _authRepo = locator<AuthRepository>();
  final _travelRepo = locator<TravelsRepository>();

  // UI state
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String _currentFilter = 'all';
  List<TravelEntity> _travels = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchTravelData();
  }

  void _initializeAnimations() {
    // Setup fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Setup slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );

    // Setup list animation controller
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<void> _fetchTravelData() async {
    try {
      final travelData = await _getTravelData();
      setState(() {
        _travels = travelData;
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
      _listController.forward();
    } catch (e) {
      log(e.toString());
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackbar('Failed to load travel data');
    }
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
        .where((travel) => travel.travelStatus != TravelStatus.ON_GOING)
        .map((travel) => TravelEntity.fromModel(travel))
        .toList();
  }

  List<TravelEntity> _getFilteredTravels() {
    if (_currentFilter == 'all') {
      return _travels;
    }

    // Filter by travel status
    TravelStatus filterStatus;
    switch (_currentFilter) {
      case 'ongoing':
        filterStatus = TravelStatus.ON_GOING;
        break;
      case 'completed':
        filterStatus = TravelStatus.COMPLETED;
        break;
      case 'cancelled':
        filterStatus = TravelStatus.CANCELLED;
        break;

      default:
        return _travels;
    }

    return _travels
        .where((travel) => travel.travelStatus == filterStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Travel History'),
        actions: _buildAppBarActions(),
      ),
      body: _isLoading ? const LoadingIndicator() : _buildContent(),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [_buildFilterChips(), Expanded(child: _buildTravelsList())],
    );
  }

  Widget _buildFilterChips() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterChip('All', 'all'),
              _buildFilterChip('Completed', 'completed'),
              _buildFilterChip('Cancelled', 'cancelled'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _currentFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentFilter = filter;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.blackColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.whiteColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      // SlideTransition(
      //   position: _slideAnimation,
      //   child: FadeTransition(
      //     opacity: _fadeAnimation,
      //     child: IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed:
      //           () => showSearch(
      //             context: context,
      //             delegate: TripSearchDelegate(_travels),
      //           ),
      //     ),
      //   ),
      // ),
      SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/acorn_logo.png', height: 32),
          ),
        ),
      ),
    ];
  }

  Widget _buildTravelsList() {
    final filteredTravels = _getFilteredTravels();

    if (filteredTravels.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _fetchTravelData();
      },
      child: AnimatedList(
        key: GlobalKey<AnimatedListState>(),
        initialItemCount: filteredTravels.length,
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index, animation) {
          final travel = filteredTravels[index];
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0.5, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuint)),
            ),
            child: FadeTransition(
              opacity: animation,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTravelCard(travel),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_currentFilter) {
      case 'completed':
        message = 'No completed trips yet';
        icon = Icons.flight_land;
        break;
      case 'ongoing':
        message = 'No ongoing trips';
        icon = Icons.flight_takeoff;
        break;
      case 'cancelled':
        message = 'No cancelled trips';
        icon = Icons.cancel;
        break;
      default:
        message = 'No travel history found';
        icon = Icons.luggage;
    }

    return EmptyState(
      message: message,
      icon: icon,
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _fetchTravelData();
      },
    );
  }

  Widget _buildTravelCard(TravelEntity travel) {
    String formattedDate =
        '${travel.createdAt.year}-${travel.createdAt.month}-${travel.createdAt.day}';
    String formattedTime =
        '${travel.createdAt.hour}:${travel.createdAt.minute.toString().padLeft(2, '0')}';

    return Hero(
      tag: 'travel_${travel.id}',
      child: FlightInfoCard(
        origin: travel.startingLocation,
        destination: travel.destination,
        date: formattedDate,
        time: formattedTime,
        status: _getTravelStatusString(travel.travelStatus),
        onViewMore: () {
          AppRoutes.navigateTo(
            context,
            AppRoutes.historyDetail,
            arguments: {'historyId': travel.id, 'travelEntity': travel},
          );
        },
      ),
    );
  }

  String _getTravelStatusString(TravelStatus status) {
    switch (status) {
      case TravelStatus.ON_GOING:
        return 'Ongoing';
      case TravelStatus.COMPLETED:
        return 'Completed';
      case TravelStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
