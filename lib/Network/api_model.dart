
import 'dart:convert';
import 'dart:io';

import 'package:license_plate_number/Network/api_methods.dart';
import 'package:http/http.dart' as http;

class ApiModel extends ApiMethods {
  @override
  Future<void> setApiToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse("https://a.techcarrel.in/api/location_save"),
        body: json.encode({
        {
         "latitude": "26.2124°",
         "longitude": "78.1772°"
         }

        }),
        headers: {"Content-Type": "application/json","Authorization" : token},
      );
      var body = await jsonDecode(response.body);
      if (response.statusCode == 200) {

      }

    } on SocketException {
      }
    }

  @override
  Future<void> postResponseApi() {
    // TODO: implement postResponseApi
    throw UnimplementedError();
  }




}
