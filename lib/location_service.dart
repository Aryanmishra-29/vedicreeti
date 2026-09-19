import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  static LocationService get instance => _instance;
  final ValueNotifier<Position?> currentPositionNotifier = ValueNotifier<Position?>(null);
  StreamSubscription<Position>? _positionStreamSubscription;
  Future<void> startLocationTracking(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them in settings.')),
        );
      }
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
      }
      return;
    }
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 1000, // Update only if moved by 1km
      ),
    ).listen((Position position) {
      currentPositionNotifier.value = position;
    });
    await forceRefreshLocation(context);
  }
  Future<void> forceRefreshLocation(BuildContext context) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      currentPositionNotifier.value = position;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch location.')),
        );
      }
    }
  }
  void dispose() {
    _positionStreamSubscription?.cancel();
    currentPositionNotifier.dispose();
  }
}
