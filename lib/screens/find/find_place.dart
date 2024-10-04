import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindPlace extends StatefulWidget {
  const FindPlace({Key? key}) : super(key: key);

  @override
  _FindPlaceState createState() => _FindPlaceState();
}

class _FindPlaceState extends State<FindPlace> {
  final TextEditingController _locationController = TextEditingController();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.chevron_left_rounded),),
        title: LocalizationController.getInstance().getTranslatedValue("Find Place"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)], centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
                    zoom: 12,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    color: Colors.white,
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Enter location',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToLocation,
            child: Text('Navigate'),
          ),
        ],
      ),
    );
  }

  void _navigateToLocation() {
    String location = _locationController.text;

    // Use a geocoding service (e.g., Google Geocoding API) to get the LatLng from the location string.
    // For this example, we'll use a dummy location.
    LatLng selectedLocation = LatLng(37.7749, -122.4194);

    // Clear the previous marker, if any.
    _markers.clear();

    // Add a new marker for the selected location.
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('selectedLocation'),
        position: selectedLocation,
      ));
    });

    // Move the camera to the selected location.
    _mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation));
  }
}
