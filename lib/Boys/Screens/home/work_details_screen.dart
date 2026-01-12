import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../Manager/Models/event_model.dart';
import '../../../services/location_service.dart';

class WorkDetailsScreen extends StatefulWidget {
  final EventModel work;

  const WorkDetailsScreen({super.key, required this.work});

  @override
  State<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends State<WorkDetailsScreen> {
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  Future<void> loadLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      currentPosition = position;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Work Details'),
        elevation: 0,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// MAP SECTION
          SizedBox(
            height: 280,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.work.latitude,
                  widget.work.longitude,
                ),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('work'),
                  position: LatLng(
                    widget.work.latitude,
                    widget.work.longitude,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('me'),
                  position: LatLng(
                    currentPosition!.latitude,
                    currentPosition!.longitude,
                  ),
                ),
              },
            ),
          ),

          /// DETAILS SECTION
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      widget.work.eventName,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    /// DESCRIPTION
                    Text(
                      widget.work.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 24),

                    /// INFO ROWS
                    _infoRow(
                      icon: Icons.location_on,
                      label: 'Work Location',
                      value:
                      '${widget.work.latitude}, ${widget.work.longitude}',
                    ),

                    const SizedBox(height: 12),

                    _infoRow(
                      icon: Icons.my_location,
                      label: 'Your Location',
                      value:
                      '${currentPosition!.latitude}, ${currentPosition!.longitude}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
