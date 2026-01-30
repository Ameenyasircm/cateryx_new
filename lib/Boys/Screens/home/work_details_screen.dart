import 'dart:convert';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../Constants/colors.dart';
import '../../../Manager/Models/event_model.dart';
import '../../../core/utils/alert_utils.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/utils/extensions/context_extensions.dart';
import '../../../core/utils/loader/loader.dart';
import '../../../core/utils/snackBarNotifications/snackBar_notifications.dart';
import '../../../services/event_service.dart';
import '../../../services/location_service.dart';

class WorkDetailsScreen extends StatefulWidget {
  final EventModel work;
  final String? userId;
  final String fromWhere;
  const WorkDetailsScreen({super.key, required this.work,required this.fromWhere,this.userId});

  @override
  State<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends State<WorkDetailsScreen> {
  final EventService _service = EventService();
  Position? currentPosition;
  List<LatLng> polylineCoordinates = [];
  String currentLocationAddress = "Loading...";
  double? routeDistance;
  // ✅ FREE OpenRouteService API Key (get yours at openrouteservice.org)
  final String openRouteServiceApiKey = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjFlYzMwZTQ1MjEyZTQyZmZhYTlkYzYzMzhlZjEzZDRmIiwiaCI6Im11cm11cjY0In0=";

  GoogleMapController? mapController;
  bool isPolylineLoading = false;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  // ✅ FREE METHOD using OpenRouteService
  Future<void> getPolylineOpenRouteService() async {
    if (currentPosition == null) return;

    setState(() {
      isPolylineLoading = true;
      polylineCoordinates.clear();
      routeDistance = null; // ✅ RESET distance
    });

    try {
      final url = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?'
              'start=${currentPosition!.longitude},${currentPosition!.latitude}&'
              'end=${widget.work.longitude},${widget.work.latitude}'
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': openRouteServiceApiKey,
          'Content-Type': 'application/json',
        },
      );

      debugPrint("==================");
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("==================");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['features'][0]['geometry']['coordinates'];

        // ✅ EXTRACT DISTANCE (in meters, convert to km)
        final distanceInMeters = data['features'][0]['properties']['segments'][0]['distance'];

        setState(() {
          polylineCoordinates = coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
          routeDistance = distanceInMeters / 1000; // ✅ Convert to kilometers
        });

        debugPrint("✅ SUCCESS: ${polylineCoordinates.length} points loaded");
        debugPrint("✅ DISTANCE: ${routeDistance!.toStringAsFixed(2)} km");
      } else {
        debugPrint("❌ FAILED: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not load route: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ EXCEPTION: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      isPolylineLoading = false;
    });
  }


  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build a readable address
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality}, ';
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          address += '${place.administrativeArea}';
        }

        return address.isNotEmpty ? address : 'Unknown location';
      }
    } catch (e) {
      debugPrint("Error getting address: $e");
    }

    return '$latitude, $longitude';
  }
  Future<void> loadLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      currentPosition = position;
    });
    currentLocationAddress = await getAddressFromCoordinates(
      currentPosition!.latitude,
      currentPosition!.longitude,
    );
    await getPolylineOpenRouteService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Work Details'),
        elevation: 0,
        actions: [
          if (currentPosition != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: getPolylineOpenRouteService,
              tooltip: 'Reload Route',
            ),
        ],
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// MAP SECTION
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
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
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'Work Location'),
                    ),
                    Marker(
                      markerId: const MarkerId('me'),
                      position: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                      infoWindow: const InfoWindow(title: 'Your Location'),
                    ),
                  },
                  polylines: polylineCoordinates.isNotEmpty
                      ? {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      color: Colors.blue,
                      width: 5,
                      points: polylineCoordinates,
                      geodesic: true,
                    ),
                  }
                      : {},
                ),
                if (isPolylineLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Loading route...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
                      value:widget.work.locationName
                      // '${widget.work.latitude}, ${widget.work.longitude}',
                    ),

                    const SizedBox(height: 12),

                    _infoRow(
                      icon: Icons.my_location,
                      label: 'Your Location',
                      value:currentLocationAddress
                      // '${currentPosition!.latitude}, ${currentPosition!.longitude}',
                    ),

                    const SizedBox(height: 12),
                    _infoRow(
                      icon: Icons.route,
                      label: 'Distance',
                      value: isPolylineLoading
                          ? 'Calculating...'
                          : routeDistance == null
                          ? 'No route available'
                          : '${routeDistance!.toStringAsFixed(2)} km (${(routeDistance! * 0.621371).toStringAsFixed(2)} mi)',
                    ),
                    const SizedBox(height: 12),

                    // _infoRow(
                    //   icon: Icons.route,
                    //   label: 'Route Status',
                    //   value: isPolylineLoading
                    //       ? 'Loading...'
                    //       : polylineCoordinates.isEmpty
                    //       ? 'No route available'
                    //       : '✓ Route loaded (${polylineCoordinates.length} points)',
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: widget.fromWhere=="available"?true:false,
        child: Padding(
          padding:EdgeInsets.symmetric(horizontal: 20.w,vertical: 25.h),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final confirmed = await showConfirmDialog(
                  context: context,
                  title: 'Take this work?',
                  message: 'Do you want to take ${widget.work.eventName}?',
                  confirmText: 'Confirm',
                );

                if (!confirmed) return;

                showLoader(context);

                try {
                  await _service.takeWork(widget.work.eventId, widget.userId??"");

                  hideLoader(context);

                  await showSuccessAlert(
                  context: context,
                  title: 'Success',
                  message: 'Work confirmed successfully',
                  );

                } catch (e) {
                  hideLoader(context);
                  NotificationSnack.showError(e.toString());

                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red22,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Take Work",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
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