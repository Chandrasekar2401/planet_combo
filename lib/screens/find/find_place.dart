import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Add geocoding dependency in pubspec.yaml

class FindPlace extends StatefulWidget {
  const FindPlace({Key? key}) : super(key: key);

  @override
  _FindPlaceState createState() => _FindPlaceState();
}

class _FindPlaceState extends State<FindPlace> {
  final TextEditingController _locationController = TextEditingController();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  String _address = "";
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Find Place"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_locationController.text),
                ),
              ),
              onSubmitted: (value) {
                _searchLocation(value);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _markers,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(37.7749, -122.4194), // Default location
                        zoom: 12,
                      ),
                      onTap: _handleTap,
                      onCameraIdle: _updateAddress,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: () => _searchLocation(_locationController.text),
                      child: const Icon(Icons.navigation),
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Latitude", _latitude),
                  const SizedBox(height: 8),
                  _buildInfoRow("Longitude", _longitude),
                  const SizedBox(height: 8),
                  _buildInfoRow("Address", _address, isAddress: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value != null ? value.toString() : "Fetching...",
            style: TextStyle(
              color: Colors.black87,
              fontSize: isAddress ? 14 : 16,
              fontWeight: isAddress ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _searchLocation(String location) async {
    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        LatLng position = LatLng(locations[0].latitude, locations[0].longitude);
        _updateMarker(position);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
      } else {
        print('Location not found');
      }
    } catch (e) {
      print('Error finding location: $e');
    }
  }

  void _handleTap(LatLng position) {
    _updateMarker(position);
  }

  Future<void> _updateAddress() async {
    if (_latitude != null && _longitude != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _latitude!,
          _longitude!,
        );
        if (placemarks.isNotEmpty) {
          setState(() {
            _address = "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}";
          });
        }
      } catch (e) {
        print('Error retrieving address: $e');
      }
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateMarker(newPosition);
          },
        ),
      );
      _updateAddress();
    });
  }
}
