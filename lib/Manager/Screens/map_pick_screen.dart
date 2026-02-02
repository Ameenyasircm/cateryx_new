// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
//
// class MapPickerScreen extends StatefulWidget {
//   const MapPickerScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   LatLng selectedLatLng = const LatLng(11.2588, 75.7804); // Default Kerala
//   Marker? marker;
//   String selectedAddress = "Tap on map to pick location";
//
//   /// 🔥 Get address from lat/lng
//   Future<void> _updateAddress(LatLng latLng) async {
//     try {
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
//
//       final place = placemarks.first;
//
//       setState(() {
//         selectedAddress =
//         "${place.name}, ${place.locality}, ${place.administrativeArea}";
//       });
//     } catch (e) {
//       setState(() {
//         selectedAddress = "Selected Location";
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Pick Location")),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: selectedLatLng,
//               zoom: 14,
//             ),
//             onTap: (latLng) async {
//               setState(() {
//                 selectedLatLng = latLng;
//                 marker = Marker(
//                   markerId: const MarkerId("selected"),
//                   position: latLng,
//                 );
//               });
//
//               await _updateAddress(latLng);
//             },
//             markers: marker != null ? {marker!} : {},
//           ),
//
//           /// 🔥 Floating address box
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
//                 ],
//               ),
//               child: Text(
//                 selectedAddress,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//
//           /// 🔥 Fixed bottom button
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Colors.deepOrange,
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context, {
//                     "address": selectedAddress,
//                     "lat": selectedLatLng.latitude,
//                     "lng": selectedLatLng.longitude,
//                   });
//                 },
//                 child: const Text(
//                   "Select This Location",
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selectedLatLng = const LatLng(11.2588, 75.7804);
  Marker? marker;
  String selectedAddress = "Fetching your location...";
  GoogleMapController? _mapController;
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];
  bool showSearchResults = false;
  DateTime? _lastRequestTime;

  @override
  void initState() {
    super.initState();
    // Show map immediately, load location in background
    _initializeMap();
    _getCurrentLocation(); // Non-blocking
  }

  void _initializeMap() {
    // Set initial marker immediately so map shows right away
    if (mounted) {
      try {
        setState(() {
          marker = Marker(
            markerId: const MarkerId("selected"),
            position: selectedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
          selectedAddress = "Tap on map to pick location";
          isLoading = false; // Don't block UI
        });
      } catch (e) {
        print("setState error in _initializeMap: $e");
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Rate limiting
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final diff = DateTime.now().difference(_lastRequestTime!);
      if (diff.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - diff.inMilliseconds));
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// 🔥 Get current location (non-blocking)
  Future<void> _getCurrentLocation() async {
    try {
      if (!mounted) return;
      
      // Update UI to show we're fetching (non-blocking)
      if (mounted) {
        try {
          setState(() {
            selectedAddress = "Fetching your location...";
          });
        } catch (e) {
          print("setState error: $e");
        }
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          try {
            setState(() {
              selectedAddress = "Tap on map to pick location";
            });
          } catch (e) {
            print("setState error: $e");
          }
        }
        _showSnackBar("Location services disabled");
        await _updateAddressFromLatLng(selectedLatLng);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            try {
              setState(() {
                selectedAddress = "Tap on map to pick location";
              });
            } catch (e) {
              print("setState error: $e");
            }
          }
          _showSnackBar("Location permission denied");
          await _updateAddressFromLatLng(selectedLatLng);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          try {
            setState(() {
              selectedAddress = "Tap on map to pick location";
            });
          } catch (e) {
            print("setState error: $e");
          }
        }
        _showSnackBar("Enable location in settings");
        await _updateAddressFromLatLng(selectedLatLng);
        return;
      }

      // Use medium accuracy for faster response
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      if (!mounted) return;

      final currentLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        try {
          setState(() {
            selectedLatLng = currentLatLng;
            marker = Marker(
              markerId: const MarkerId("selected"),
              position: currentLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
          });
        } catch (e) {
          print("setState error: $e");
        }
      }

      // Move camera to current location (non-blocking)
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 15),
      );

      // Update address in background (non-blocking)
      _updateAddressFromLatLng(currentLatLng);
      _showSnackBar("Current location found!");

    } catch (e) {
      print("Location error: $e");
      if (mounted) {
        try {
          setState(() {
            selectedAddress = "Tap on map to pick location";
          });
        } catch (setStateError) {
          print("setState error (widget disposed): $setStateError");
        }
      }
      _updateAddressFromLatLng(selectedLatLng);
      _showSnackBar("Using default location");
    }
  }

  /// 🔥 Search location using Nominatim (FREE)
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    if (!mounted) return;

    try {
      if (mounted) {
        try {
          setState(() {
            isSearching = true;
            showSearchResults = true;
          });
        } catch (e) {
          print("setState error: $e");
          return;
        }
      }

      await _respectRateLimit();
      if (!mounted) return;

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
            'q=${Uri.encodeComponent(query)}'
            '&format=json'
            '&limit=5'
            '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterMapApp/1.0 (contact@yourapp.com)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          _showSnackBar("No results found");
          if (mounted) {
            try {
              setState(() {
                searchResults = [];
                showSearchResults = false;
                isSearching = false;
              });
            } catch (e) {
              print("setState error: $e");
            }
          }
          return;
        }

        if (mounted) {
          try {
            setState(() {
              searchResults = data.map((item) {
                return {
                  'display_name': item['display_name'] ?? 'Unknown',
                  'lat': double.tryParse(item['lat'].toString()) ?? 0.0,
                  'lon': double.tryParse(item['lon'].toString()) ?? 0.0,
                };
              }).toList();
              isSearching = false;
            });
          } catch (e) {
            print("setState error: $e");
          }
        }
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      print("Search error: $e");
      if (mounted) {
        try {
          setState(() {
            isSearching = false;
            showSearchResults = false;
          });
        } catch (setStateError) {
          print("setState error (widget disposed): $setStateError");
        }
      }
      _showSnackBar("Search failed. Try again.");
    }
  }

  /// 🔥 Reverse geocoding using Nominatim (FREE) - Non-blocking
  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    if (!mounted) return;
    
    try {
      await _respectRateLimit();
      
      if (!mounted) return;

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
            'lat=${latLng.latitude}'
            '&lon=${latLng.longitude}'
            '&format=json'
            '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterMapApp/1.0 (contact@yourapp.com)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            selectedAddress = data['display_name'] ?? "Selected Location";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedAddress = "Lat: ${latLng.latitude.toStringAsFixed(6)}, "
                "Lng: ${latLng.longitude.toStringAsFixed(6)}";
          });
        }
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
      if (mounted) {
        try {
          setState(() {
            selectedAddress = "Lat: ${latLng.latitude.toStringAsFixed(6)}, "
                "Lng: ${latLng.longitude.toStringAsFixed(6)}";
          });
        } catch (setStateError) {
          // Widget was disposed during setState, ignore
          print("setState error (widget disposed): $setStateError");
        }
      }
    }
  }

  /// 🔥 Select search result and GOTO red marker
  void _selectSearchResult(Map<String, dynamic> result) {
    if (!mounted) return;
    
    final searchedLatLng = LatLng(result['lat'], result['lon']);

    try {
      setState(() {
        selectedLatLng = searchedLatLng;
        marker = Marker(
          markerId: const MarkerId("selected"),
          position: searchedLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
        selectedAddress = result['display_name'];
        showSearchResults = false;
        searchResults = [];
      });
    } catch (e) {
      print("setState error in _selectSearchResult: $e");
    }

    // 🔥 GOTO red marker with smooth animation
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(searchedLatLng, 16),
    );

    searchController.clear();
    FocusScope.of(context).unfocus();

    _showSnackBar("Location selected!");
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: "Current Location",
          ),
        ],
      ),
      body: Stack(
        children: [
          /// 🔥 Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLatLng,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              if (!mounted) return;
              try {
                setState(() {
                  selectedLatLng = latLng;
                  marker = Marker(
                    markerId: const MarkerId("selected"),
                    position: latLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  );
                  showSearchResults = false;
                  selectedAddress = "Loading address...";
                });
              } catch (e) {
                print("setState error in onTap: $e");
              }
              // Update address in background (non-blocking)
              _updateAddressFromLatLng(latLng);
            },
            markers: marker != null ? {marker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          /// 🔥 Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search location...",
                      prefixIcon: isSearching
                          ? Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.deepOrange,
                          ),
                        ),
                      )
                          : Icon(Icons.search, color: Colors.deepOrange),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          if (mounted) {
                            try {
                              setState(() {
                                showSearchResults = false;
                                searchResults = [];
                              });
                            } catch (e) {
                              print("setState error: $e");
                            }
                          }
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      if (mounted) {
                        try {
                          setState(() {});
                        } catch (e) {
                          // Ignore setState errors in onChanged
                        }
                      }
                    },
                    onSubmitted: _searchLocation,
                    textInputAction: TextInputAction.search,
                  ),
                ),

                /// Search results
                if (showSearchResults && searchResults.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          leading: Icon(Icons.location_on,
                              color: Colors.deepOrange),
                          title: Text(
                            result['display_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          /// Address display
          Positioned(
            top: showSearchResults && searchResults.isNotEmpty ? 280 : 80,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.deepOrange, size: 20),
                  SizedBox(width: 8),
                  if (isLoading && selectedAddress.contains("Fetching"))
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (isLoading && selectedAddress.contains("Fetching"))
                    SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedAddress,
                      style: TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Select button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  "address": selectedAddress,
                  "lat": selectedLatLng.latitude,
                  "lng": selectedLatLng.longitude,
                });
              },
              child: Text(
                "Select This Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Removed blocking loading overlay - map shows immediately
        ],
      ),
    );
  }
}