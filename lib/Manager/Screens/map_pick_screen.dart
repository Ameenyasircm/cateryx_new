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
  String selectedAddress = "Tap on map to pick location";

  /// 🔥 Get address from lat/lng
  Future<void> _updateAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      final place = placemarks.first;

      setState(() {
        selectedAddress =
        "${place.name}, ${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      setState(() {
        selectedAddress = "Selected Location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 14,
            ),
            onTap: (latLng) async {
              setState(() {
                selectedLatLng = latLng;
                marker = Marker(
                  markerId: const MarkerId("selected"),
                  position: latLng,
                );
              });

              await _updateAddress(latLng);
            },
            markers: marker != null ? {marker!} : {},
          ),

          /// 🔥 Floating address box
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Text(
                selectedAddress,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          /// 🔥 Fixed bottom button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    "address": selectedAddress,
                    "lat": selectedLatLng.latitude,
                    "lng": selectedLatLng.longitude,
                  });
                },
                child: const Text(
                  "Select This Location",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
