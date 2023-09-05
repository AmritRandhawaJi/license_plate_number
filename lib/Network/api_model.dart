import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:license_plate_number/Network/api_methods.dart';
import 'package:http/http.dart' as http;
import 'package:license_plate_number/Utils/app_exception.dart';

class ApiModel extends ApiMethods {
  final database = FirebaseFirestore.instance;

  @override
  Future<void> getApiToken(
      {required String plateNumber, required String deviceName}) async {
    try {
      final response = await http.post(
        Uri.parse("https://a.techcarrel.in/api/save_plate_number"),
        body: json
            .encode({"plate_number": plateNumber, "device_name": deviceName}),
        headers: {"Content-Type": "application/json"},
      );
      var body = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (body["token"] != null) {
          await database
              .collection("userId")
              .doc("token")
              .set({'token': body["token"]});
          ResponseServer.result = true;
          ResponseServer.messege = body["message"];
        } else {
          ResponseServer.result = false;
          ResponseServer.messege = "Invalid Response";
          InvalidResponse(response.statusCode.toString()).toError();
        }
      }
    } on SocketException {
      ResponseServer.result = false;
      ResponseServer.messege = "Internet Error";
      throw InternetError("Connectivity").toError();
    }
  }

  @override
  Future<void> postResponseApi(Position position) async {
    String? token;
    try {
      await database.collection("userId").doc("token").get().then((value) => {
            token = value["token"],
          });

      final deviceInfo = DeviceInfoPlugin();
      final response = await http.post(
        Uri.parse("https://a.techcarrel.in/api/location_save"),
        body: json.encode({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "Timestamp": DateTime.now().toIso8601String(),
          "Device": deviceInfo.androidInfo.toString()
        }),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token.toString()
        },
      );
      var body = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (body["token"] != null) {
          await database
              .collection("userId")
              .doc("token")
              .set({'token': body["token"]});
          ResponseServer.result = true;
          ResponseServer.messege = body["message"];
        } else {
          ResponseServer.result = false;
          ResponseServer.messege = "Invalid Response";
          InvalidResponse(response.statusCode.toString()).toError();
        }
      }
    } on FirebaseException {
      if (kDebugMode) {
        throw InvalidResponse("Firebase database error").toError();
      }
    } on SocketException {
      ResponseServer.result = false;
      ResponseServer.messege = "Internet Error";
      throw InternetError("Connectivity").toError();
    }
  }
}

class ResponseServer {
  static late bool result;
  static late String messege;
}
