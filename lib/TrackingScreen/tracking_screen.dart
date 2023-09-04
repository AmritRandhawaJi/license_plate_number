import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:license_plate_number/Network/api_model.dart';
import 'package:license_plate_number/Utils/auth_errors.dart';
import 'package:license_plate_number/permissions.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with WidgetsBindingObserver {
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final _plateKey = GlobalKey<FormState>();
  final _deviceKey = GlobalKey<FormState>();
  final TextEditingController plateNumber = TextEditingController();
  final TextEditingController deviceName = TextEditingController();
  var client = http.Client();

  Future<void> getApiToken() async {
    try {
      final response = await client.post(
        Uri.parse("https://a.techcarrel.in/api/save_plate_number"),
        body: json.encode({
          "plate_number": plateNumber.value.text.toUpperCase().toString(),
          "device_name": deviceName.value.text.toUpperCase().toString()
        }),
        headers: {"Content-Type": "application/json"},
      );
      var body = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (body["token"] != null) {
          showSuccess(body["message"], body["token"]);
        }
      }

      /// can use switch case for different kind of errors
      else {
        if (mounted) {
          loading.value = false;
          AuthErrors.flushBarAuth("Something went wrong", context);
        }
      }
    } on SocketException {
      if (mounted) {
        loading.value = false;
        AuthErrors.flushBarAuth("internet error", context);
      }
    }
  }

  @override
  void dispose() {
    plateNumber.dispose();
    deviceName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    var ref = PermissionsCheck();
    ref.determinePosition();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _plateKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Plate Number";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Enter Plate Number",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
              ),
            ),
            Form(
              key: _deviceKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Enter Device Name";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      hintText: "Enter Device Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
              child: ValueListenableBuilder(
                valueListenable: loading,
                builder: (BuildContext context, value, Widget? child) {
                  return loading.value
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 10),
                          child: CupertinoButton(
                              color: Colors.red,
                              onPressed: () {},
                              child: const Text("Stop Tracking")),
                        )
                      : CupertinoButton(
                          color: Colors.green,
                          onPressed: () {
                            if (_plateKey.currentState!.validate() &
                                _deviceKey.currentState!.validate()) {
                              loading.value = true;
                              getApiToken();
                            }
                          },

                          /// it will hit api to proceed further
                          child: const Text("Start Tracking"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSuccess(String message, String token) {
    var value = ApiModel();
    value.setApiToken(token);
    showDialog(
      barrierDismissible: false,
      useSafeArea: true,
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text("Success", style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);

                  loading.value = false;
                },
                child: const Text("Ok"))
          ]),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onPaused();
        break;
      case AppLifecycleState.paused:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
    }
  }

  Future<void> onResumed() async {
  }

  void onPaused() {}

  void onInactive() {}
  void onHidden() {}

  void onDetached() {


  }
}
