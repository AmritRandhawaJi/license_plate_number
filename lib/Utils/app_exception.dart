import 'package:flutter/cupertino.dart';
import 'package:license_plate_number/Utils/auth_errors.dart';

class AppException implements Exception{


  static void internetError(BuildContext context){
    AuthErrors.flushBarAuth("Connection error", context);
  }

  static void invalidRequest(BuildContext context){
    AuthErrors.flushBarAuth("Invalid request", context);
  }
}