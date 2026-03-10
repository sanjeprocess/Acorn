import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/incident_repository.dart';
import '../../widgets/custom_scaffold.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final _incidentRepository = locator<IncidentRepository>();
  final _authRepository = locator<AuthRepository>();

  final List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  // Current selected location coordinates
  double _latitude = 0;
  double _longitude = 0;

  // Flag to check if location permission is granted
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    // Check location permission on init
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Check if location permission is granted
  Future<void> _checkLocationPermission() async {
    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return;
        }
      }

      setState(() {
        _locationPermissionGranted = true;
      });
    } catch (e) {
      log('Error checking location permission: $e');
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = Location();

      if (!_locationPermissionGranted) {
        await _checkLocationPermission();
        if (!_locationPermissionGranted) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      final locationData = await location.getLocation();

      // Update the selected location
      setState(() {
        _latitude = locationData.latitude ?? 0.0;
        _longitude = locationData.longitude ?? 0.0;
        _locationController.text =
            'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
        _isLoadingLocation = false;
      });
    } catch (e) {
      log('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to get location')));
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Manual entry of coordinates dialog
  Future<void> _showManualCoordinatesDialog() async {
    final TextEditingController latController = TextEditingController(
      text: _latitude != 0 ? _latitude.toString() : '',
    );
    final TextEditingController lngController = TextEditingController(
      text: _longitude != 0 ? _longitude.toString() : '',
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Coordinates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'Enter latitude (e.g., 37.7749)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'Enter longitude (e.g., -122.4194)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final double lat = double.parse(latController.text);
                  final double lng = double.parse(lngController.text);

                  if (lat < -90 || lat > 90) {
                    throw Exception('Latitude must be between -90 and 90');
                  }
                  if (lng < -180 || lng > 180) {
                    throw Exception('Longitude must be between -180 and 180');
                  }

                  setState(() {
                    _latitude = lat;
                    _longitude = lng;
                    _locationController.text =
                        'Lat: ${_latitude.toStringAsFixed(6)}, Lng: ${_longitude.toStringAsFixed(6)}';
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid coordinates: ${e.toString()}'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    latController.dispose();
    lngController.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final UserModel? userModel = await _authRepository.getCurrentUser();

    if (userModel == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
        Navigator.of(context).pop(true);
      }
      return;
    }

    try {
      final String customer = userModel.id;
      final String title = _titleController.text.trim();
      final String notes = _descriptionController.text.trim();
      final List<File> images = _selectedImages;

      await _incidentRepository.createIncident(
        title,
        customer,
        LocationModel(longitude: _longitude, latitude: _latitude),
        notes,
        images,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support request submitted to CSA')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Support Request'),
        titleTextStyle: AppTheme.headerStyle,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Details',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Title Field
                      TextFormField(
                        cursorColor: AppTheme.whiteColor,
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter a brief title for the incident',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        cursorColor: AppTheme.whiteColor,
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe what happened',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location Field with options
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),

                          // Show coordinates card if location is selected
                          if (_latitude != 0 && _longitude != 0)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Coordinates',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCoordinateCard(
                                          'Latitude',
                                          _latitude.toStringAsFixed(6),
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildCoordinateCard(
                                          'Longitude',
                                          _longitude.toStringAsFixed(6),
                                          theme,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: AppTheme.whiteColor,
                                  controller: _locationController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Coordinates',
                                    hintText: 'No location selected',
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        _latitude == 0) {
                                      return 'Please select a location';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              // const SizedBox(width: 8),
                              // ElevatedButton.icon(
                              //   onPressed:
                              //       _isLoadingLocation
                              //           ? null
                              //           : _showManualCoordinatesDialog,
                              //   icon: const Icon(Icons.edit_location),
                              //   label: const Text('Edit'),
                              // ),
                            ],
                          ),

                          // Location options
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isLoadingLocation
                                          ? null
                                          : _getCurrentLocation,
                                  icon:
                                      _isLoadingLocation
                                          ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Icon(Icons.my_location),
                                  label: const Text('Use Current Location'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Photo Upload Section
                      Text('Photos', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Add photos related to the incident (optional)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Photo Grid
                      if (_selectedImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 16),

                      // Add Photo Button
                      OutlinedButton.icon(
                        onPressed:
                            _selectedImages.length >= 5 ? null : _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          _selectedImages.isEmpty
                              ? 'Add Photos'
                              : '${_selectedImages.length}/5 Photos',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit Report'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCoordinateCard(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
