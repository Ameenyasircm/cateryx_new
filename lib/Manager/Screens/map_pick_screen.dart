import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selectedLatLng = const LatLng(11.2588, 75.7804); // Default Kerala
  Marker? marker;

  Future<String> _getAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      final place = placemarks.first;
      return "${place.name}, ${place.locality}, ${place.administrativeArea}";
    } catch (_) {
      return "Selected Location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: () async {
              final address = await _getAddress(selectedLatLng);
              Navigator.pop(context, {
                "address": address,
                "lat": selectedLatLng.latitude,
                "lng": selectedLatLng.longitude,
              });
            },
            child: const Text(
              "CONFIRM",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLatLng,
          zoom: 14,
        ),
        onTap: (latLng) {
          setState(() {
            selectedLatLng = latLng;
            marker = Marker(
              markerId: const MarkerId("selected"),
              position: latLng,
            );
          });
        },
        markers: marker != null ? {marker!} : {},
      ),
    );
  }
}
