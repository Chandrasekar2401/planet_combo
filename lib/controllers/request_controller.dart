import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';

class HoroscopeRequestController extends GetxController {
  static HoroscopeRequestController? _instance;

  static HoroscopeRequestController getInstance() {
    _instance ??= HoroscopeRequestController();
    return _instance!;
  }

  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  RxInt selectedRequest = 0.obs;

  RxBool deviceCurrentLocationFound = false.obs;

  Rx<DateTime> currentTime = DateTime.now().obs;


// First, the location request function
  Future<bool> getCurrentLocation(context) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomDialog.cancelLoading(context);
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text(
                kIsWeb
                    ? 'Please refresh or open new tab and allow location access'
                    : 'Please enable GPS on your phone Settings'
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context, false); // User cancels
                },
              ),
            ],
          ),
        );

        if (result == true) {
          return getCurrentLocation(context); // Retry if user wants to try again
        }
        return false;
      }

      // Check and request permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If denied or deniedForever, show dialog with retry option
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        CustomDialog.cancelLoading(context);
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text(
                permission == LocationPermission.denied
                    ? 'Location permission is required. Please enable and try again?'
                    : 'Please enable location access in settings and try again'
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context, false); // User cancels
                },
              ),
            ],
          ),
        );

        if (result == true) {
          return getCurrentLocation(context); // Retry if user wants to try again
        }
        return false;
      }

      // Get the current position if permissions are granted
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      // Update controller values
      applicationBaseController.deviceLatitude.value = position.latitude;
      applicationBaseController.deviceLongitude.value = position.longitude;
      deviceCurrentLocationFound.value = true;

      print('Latitude: ${applicationBaseController.deviceLatitude.value}, Longitude: ${applicationBaseController.deviceLongitude.value}');
      CustomDialog.cancelLoading(context);
      return true;

    } catch (e) {
      CustomDialog.cancelLoading(context);
      bool? result = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('Error getting location. Please check location and try again?'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
      );

      if (result == true) {
        return getCurrentLocation(context);
      }
      return false;
    }
  }


}