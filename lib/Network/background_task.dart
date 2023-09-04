
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
const eventKeys = "fetch_events";
/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask() async {
  print('[BackgroundFetch] Headless event received.');
  print("Hey Pawan Background headless fetch is successful");
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  List<String> events = [];
  String? json = prefs.getString(eventKeys);
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }
  // Add new event.
  events.insert(0, '${DateTime.now()} [Headless]');
  // Persist fetch events in SharedPreferences
  prefs.setString(eventKeys, jsonEncode(events));

  BackgroundFetch.finish("Task");
}


class BackgroundTask extends StatefulWidget {
  const BackgroundTask({super.key});

  @override
  State<BackgroundTask> createState() => _BackgroundTaskState();
}

class _BackgroundTaskState extends State<BackgroundTask> {

  bool _enabled = true;
  int _status = 0;
  List<String> _events = [];
// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString(eventKeys);
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }

    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,),
        _onBackgroundFetch)
        .then((int status) {
      print("Hey Pawan Background fetch is successful");
      print('[BackgroundFetch] SUCCESS: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // This is the fetch-event callback.
    print('[BackgroundFetch] Event received');
    setState(() {
      _events.insert(0, DateTime.now().toString());
    });
    // Persist fetch events in SharedPreferences
    prefs.setString(eventKeys, jsonEncode(_events));

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish("Task");
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _onClickClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(eventKeys);
    setState(() {
      _events = [];
    });
  }
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('BackgroundFetch Example',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amberAccent,
        actions: <Widget>[
          Switch(value: _enabled, onChanged: _onClickEnable),
        ], ),
      body: (_events.isEmpty)
          ? const Text("Empty")
          : ListView.builder(
          itemCount: _events.length,
          itemBuilder: (BuildContext context, int index) {
            String timestamp = _events[index];
            return InputDecorator(
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 5.0, top: 5.0, bottom: 5.0),
                    labelStyle:
                    TextStyle(color: Colors.blue, fontSize: 20.0),
                    labelText: "[background fetch event]"),
                child: Text(timestamp,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 16.0)));
          }),

    );
  }
}
