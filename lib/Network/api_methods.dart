import 'package:geolocator/geolocator.dart';

abstract class ApiMethods{

  Future<void> getApiToken({required String plateNumber, required String deviceName} );

  Future<void> postResponseApi(Position position);

}