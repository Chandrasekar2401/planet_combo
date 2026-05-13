import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/common/app_logger.dart';

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
    // If we already have a location for this session, don't re-prompt
    // the browser / OS — that's the source of the spurious "enable
    // location in settings" alert on web where the Permissions API can
    // intermittently report 'denied' even after a previous grant.
    if (deviceCurrentLocationFound.value == true) {
      CustomDialog.cancelLoading(context);
      return true;
    }

    try {
      // On web we deliberately skip Geolocator.isLocationServiceEnabled
      // and the checkPermission/requestPermission dance: the browser
      // Permissions API ('navigator.permissions.query') is unreliable
      // across Safari / Firefox-private / decayed Chrome permissions,
      // and on web calling getCurrentPosition is itself enough to
      // surface the live browser prompt when needed.
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          CustomDialog.cancelLoading(context);
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: const Text('Please enable GPS on your phone Settings'),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          );
          return false;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          CustomDialog.cancelLoading(context);
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: Text(
                  permission == LocationPermission.denied
                      ? 'Location permission is required. Please enable and try again?'
                      : 'Please enable location access in settings and try again'
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          );
          return false;
        }
      }

      // Try a fast last-known fix first (mobile only — web does not
      // implement getLastKnownPosition).
      if (!kIsWeb) {
        try {
          final last = await Geolocator.getLastKnownPosition();
          if (last != null) {
            applicationBaseController.deviceLatitude.value = last.latitude;
            applicationBaseController.deviceLongitude.value = last.longitude;
            deviceCurrentLocationFound.value = true;
          }
        } catch (_) {
          // Ignore — we'll try a live fetch next.
        }
      }

      // Live position fetch. High accuracy on mobile, lower on web
      // (browsers don't benefit from high-accuracy and it just slows
      // down or times out the navigator.geolocation request). The
      // timeLimit is critical on web — without it the call can hang
      // indefinitely, which the user perceives as a stuck app.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy:
              kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        ),
      );

      applicationBaseController.deviceLatitude.value = position.latitude;
      applicationBaseController.deviceLongitude.value = position.longitude;
      deviceCurrentLocationFound.value = true;

      AppLogger.d(
          'Latitude: ${applicationBaseController.deviceLatitude.value}, Longitude: ${applicationBaseController.deviceLongitude.value}');
      CustomDialog.cancelLoading(context);
      return true;
    } catch (e) {
      CustomDialog.cancelLoading(context);
      AppLogger.d('getCurrentLocation error: $e');

      // If we already populated a last-known position above, accept it
      // rather than blocking the user with an error dialog.
      if (deviceCurrentLocationFound.value == true) {
        return true;
      }

      final isPermissionError =
          e is PermissionDeniedException || e is LocationServiceDisabledException;
      final message = isPermissionError
          ? (kIsWeb
              ? 'Location permission is blocked in your browser. Click the location icon in the address bar to allow, then try again.'
              : 'Location permission is required. Please enable and try again.')
          : (kIsWeb
              ? 'Could not get your location. Please allow location in the browser prompt and try again.'
              : 'Error getting location. Please check location and try again.');

      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      );
      return false;
    }
  }


}