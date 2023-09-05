import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:license_plate_number/Network/api_model.dart';
import 'package:license_plate_number/permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Utils/auth_errors.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Tacking',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// TO make ui more responsive we can add lifecycles and see the current services going on
/// TO make ui more responsive we can add lifecycles and see the current services going on
/// TO make ui more responsive we can add lifecycles and see the current services going on
/// TO make ui more responsive we can add lifecycles and see the current services going on
/// TO make ui more responsive we can add lifecycles and see the current services going on
/// TO make ui more responsive we can add lifecycles and see the current services going on

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'SERVICE',
          'Track ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "Plate Number Tracking is Running",
          content: "Updating at ${DateTime.now()}",
        );
      }
    }
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  final GlobalKey<FormState> _deviceKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _plateKey = GlobalKey<FormState>();
  final  plateNumber = TextEditingController();
  final  deviceName = TextEditingController();

  late bool permissionResult;

  @override
  void dispose() {
    plateNumber.dispose();
    deviceName.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('License PLate Number'),
      ),
      body: Column(
        children: [
          Form(
            key: _plateKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: plateNumber,
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
                controller: deviceName,
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
          ValueListenableBuilder(valueListenable: loading, builder: (context, value, child) {
          return  loading.value ? const CircularProgressIndicator():Container();
          },),
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
                            color: Colors.green,
                            onPressed: () async {
                              final service = FlutterBackgroundService();
                              var isRunning = await service.isRunning();
                              if (isRunning) {
                                service.invoke("stopService");
                                loading.value = false;
                              } else {
                                service.startService();
                              }
                            },
                            child: const Text("Stop Tracking")),
                      )
                    : CupertinoButton(
                        color: Colors.green,
                        onPressed: () async {

                          ///validation of text-field
                          if (_plateKey.currentState!.validate() &
                              _deviceKey.currentState!.validate()) {
                            loading.value = true;

                            /// calling api for plate save
                            await ApiModel().getApiToken(
                              plateNumber: plateNumber.value.toString(),
                              deviceName: deviceName.value.toString(),
                            );

                            /// server response could be true or false
                            if (ResponseServer.result) {
                              if (mounted) {
                                Messege.flushBarAuth(
                                    ResponseServer.messege,
                                    context,
                                    const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ));
                                startBackgroundService();
                              }
                            } else {
                              if (mounted) {
                                Messege.flushBarAuth(
                                    ResponseServer.messege,
                                    context,
                                    const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ));
                              }
                            }
                          }
                        },
                        child: const Text("Start Tracking"));
              },
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> startBackgroundService() async {
    await initializeService();
    permissions();
  }

  Future<void> permissions() async {

    Position position = await PermissionsCheck.determinePosition();
    if (PermissionsCheck.permissionAllowed) {
      final service = FlutterBackgroundService();
      var isRunning = await service.isRunning();
      if (isRunning) {
        service.invoke("stopService");
      } else {
        service.startService();
      }
      var ref = ApiModel();
      ref.postResponseApi(position);

    }
  }
}
