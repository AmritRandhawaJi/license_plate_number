
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:license_plate_number/main.dart';

class PermissionsCheck{

Future<void> determinePosition(BuildContext context) async {

  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return locateMe();
}

void locateMe() async {
 var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

  Future<void> showError(BuildContext context) async {

  }


showError() {
  if (Platform.isAndroid) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Disabled"),
        content:
        const Text("Location is disabled please allow in app settings"),
        actions: [
          TextButton(
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("Allow")),
          TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(),
                    ),
                        (route) => false);
              },
              child: const Text("Cancel"))
        ],
      ),
    );
  }
  if (Platform.isIOS) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Location Disabled"),
        content:
        const Text("Location is disabled please allow in app settings"),
        actions: [
          TextButton(
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text(
                "Allow",
                style: TextStyle(color: Colors.black),
              )),
          TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const MyApp(),
                    ),
                        (route) => false);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }
}
}