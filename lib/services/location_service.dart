import 'package:flutter/foundation.dart'; 
import 'package:geolocator/geolocator.dart'; // REQUIRED: The geolocator package

class LocationService {
  // Returns a Position object containing latitude and longitude
  Future<Position?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if the phone's GPS is turned on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      // You can return null or show an error to the user here
      return null; 
    }

    // 2. Check if the user has given the app permission to use location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return null;
    }

    // 3. If GPS is on and permissions are granted, fetch the location!
    debugPrint("Fetching user location..."); 
    return await Geolocator.getCurrentPosition();
  }
}