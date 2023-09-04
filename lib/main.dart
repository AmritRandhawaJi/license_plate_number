import 'dart:async';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:license_plate_number/TrackingScreen/tracking_screen.dart';
import 'package:license_plate_number/Utils/page_router.dart';
import 'package:lottie/lottie.dart';

import 'Network/background_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MaterialApp(home: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(milliseconds: 3500), () async {
              if (mounted) {
                PageRouter.pushRemoveUntil(context, const TrackingScreen());
              }
            }));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Lottie.asset(
              'assets/splash.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..repeat();
              },
            ),
            Platform.isIOS
                ? const CupertinoActivityIndicator()
                : const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

// extension WidgetSize on num {
//   SizedBox get ph => SizedBox(
//         height: toDouble(),
//       );
//
//   SizedBox get pw => SizedBox(
//         width: toDouble(),
//       );
// }
