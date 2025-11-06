import 'package:geolocator/geolocator.dart';
import 'dart:async';

  /// Might need to implement different ways of getting location based on mobile OS.

class GeolocatorDistance {
  static StreamController<double> streamDistance = StreamController<double>();
  static LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high, // Or other desired accuracy
    distanceFilter: 3, // Minimum distance (in meters) before an update is triggered
  );

  // Call to get stream for updating UI
  Stream<double> getDistanceStream(){
    return streamDistance.stream;
  }


  void beginCalculateDistance() async {
    int i = 0;
    Position startingPoint = await _determinePosition();
    await for (Position position in Geolocator.getPositionStream(
      locationSettings: locationSettings,
    )) {
      if(i%2==0){
        startingPoint = position;
      }
      // will probably need to return stream or update state

      streamDistance.sink.add(Geolocator.distanceBetween(startingPoint.latitude, startingPoint.longitude, position.latitude, startingPoint.longitude));
      i++;
    } 
  }








  /// Determine the current position of the device.
  /// When the location services are not enabled or permissions are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
  
    final LocationSettings newLocationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
  
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
      ' Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(locationSettings: newLocationSettings);
  }
}