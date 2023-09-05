import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';

class Messege {
  static void flushBarAuth(String message, BuildContext context,Icon icon) {
    showFlushbar(context: context, flushbar: Flushbar(
      icon: icon,
      message: message,
      title: "Server",
      margin: EdgeInsets.all(MediaQuery.of(context).size.width/25),
      duration: const Duration(seconds: 5),
      messageColor: Colors.white,
      backgroundColor: Colors.black87,
      borderRadius: BorderRadius.circular(15),
    )..show(context));
  }
}
