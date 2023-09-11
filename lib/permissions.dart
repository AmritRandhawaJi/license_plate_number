import 'package:app_settings/app_settings.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

import 'Network/api_model.dart';

class PermissionsCheck {
  static bool permissionAllowed = false;
 static Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.whileInUse ||permission == LocationPermission.always){
      permissionAllowed = true;
      return  await Geolocator.getCurrentPosition();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

    }

    if (permission == LocationPermission.deniedForever) {
      AppSettings.openAppSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

}

