// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const cPrimary = Colors.green;

void notif(context, {required String text, Color color = cPrimary}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    ),
  );
}

void navigatorPushReplace(context, {dynamic page}) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (ctx) => page));
}

void navigatorPush(context, {dynamic page}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => page));
}

void navigatorPop(context) {
  Navigator.of(context).pop();
}

Future getAuth() async {
  SharedPreferences session = await SharedPreferences.getInstance();
  String auth = session.getString('auth').toString();
  var result = FirebaseDatabase.instance.ref('user').child(auth).get();
  return result;
}
