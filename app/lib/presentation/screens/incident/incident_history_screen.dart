import 'dart:developer';

import 'package:arcon_travel_app/core/theme.dart';
import 'package:arcon_travel_app/presentation/screens/incident/incident_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/incident_detail_sheet.dart';
import '../../widgets/main_bottom_navigation.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen>
    with TickerProviderStateMixin {
  List<IncidentModel> _incidents = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  int _filterDays = 0;

  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;

  final _incidentRepository = locator<IncidentRepository>();
  final _authRepository = locator<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadIncidents();
  }

  void _setupAnimations() {
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadIncidents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserModel? user = await _authRepository.getCurrentUser();

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final incidents = await _incidentRepository.getUserIncidents(user.id);

      setState(() {
        _incidents = incidents;
        _isLoading = false;
      });

      _listAnimationController.forward();
      _fabAnimationController.forward();
    } catch (e) {
      debugPrint('Error loading incidents: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showIncidentDetails(BuildContext context, IncidentModel incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            tween: Tween(begin: 1.0, end: 0.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  value * MediaQuery.of(context).size.height * 0.6,
                ),
                child: child,
              );
            },
            child: IncidentDetailsSheet(incident: incident),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Support'),

        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   onPressed: () => _showFilterDialog(context),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () => _loadIncidents(),
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/acorn_logo.png', height: 32),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _incidents.isEmpty
              ? _buildEmptyState()
              : _buildIncidentsList(),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimationController,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await AppRoutes.navigateTo(context, AppRoutes.incidentReport);
            await _loadIncidents();
          },
          label: const Text('Create Support Request'),
          icon: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: MainBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Support Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t created any support requests yet.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadIncidents,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentsList() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _incidents.length,
          itemBuilder: (context, index) {
            final incident = _incidents[index];
            final animation = CurvedAnimation(
              parent: _listAnimationController,
              curve: Interval(
                (index / _incidents.length) * 0.5,
                ((index + 1) / _incidents.length) * 0.5,
                curve: Curves.easeOut,
              ),
            );

            return IncidentCard(
              incident: incident,
              animation: animation,
              onTap: () => _showIncidentDetails(context, incident),
            );
          },
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Support Requests'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Time Period',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildFilterOption('All time', 0),
                  _buildFilterOption('Last 30 days', 30),
                  _buildFilterOption('Last 90 days', 90),
                  const Divider(height: 24),
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusOption('All statuses', 'all'),
                  _buildStatusOption('Pending', 'pending'),
                  _buildStatusOption('In Progress', 'in progress'),
                  _buildStatusOption('Resolved', 'resolved'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterDays = 0;
                    _filterStatus = 'all';
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: const Text('Reset Filters'),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterOption(String label, int days) {
    return RadioListTile<int>(
      title: Text(label),
      value: days,
      groupValue: _filterDays,
      onChanged: (value) {
        Navigator.pop(context);
        setState(() {
          _filterDays = value!;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildStatusOption(String label, String status) {
    return RadioListTile<String>(
      title: Text(label),
      value: status,
      groupValue: _filterStatus,
      onChanged: (value) {
        Navigator.pop(context);
        setState(() {
          _filterStatus = value!;
        });
        _applyFilters();
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    _loadIncidents().then((_) {
      List<IncidentModel> filteredIncidents = List.from(_incidents);

      if (_filterStatus != 'all') {
        filteredIncidents =
            filteredIncidents
                .where(
                  (incident) =>
                      incident.incidentStatus.toLowerCase() ==
                      _filterStatus.toLowerCase(),
                )
                .toList();
      }

      if (_filterDays > 0) {
        final cutoffDate = DateTime.now().subtract(Duration(days: _filterDays));
        filteredIncidents =
            filteredIncidents
                .where((incident) => incident.createdAt.isAfter(cutoffDate))
                .toList();
      }

      setState(() {
        _incidents = filteredIncidents;
        _isLoading = false;
      });

      _listAnimationController.reset();
      _listAnimationController.forward();
    });
  }
}

// Helper function for min value (similar to Dart's math.min)
int min(int a, int b) {
  return a < b ? a : b;
}
