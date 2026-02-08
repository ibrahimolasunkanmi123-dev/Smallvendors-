import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    try {
      // Request location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        return 'Location permission denied';
      }

      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        return 'Location services disabled';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}';
      }
      
      return 'Location detected';
    } catch (e) {
      return 'Unable to detect location';
    }
  }

  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }
}