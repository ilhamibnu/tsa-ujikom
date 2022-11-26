// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom/component/panel.dart';
import 'package:ujikom/layout/dashboard.dart';
import 'package:ujikom/layout/register.dart';
import 'package:ujikom/rules/index.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseDatabase fireDB = FirebaseDatabase.instance;

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    cekUser();
  }

  cekUser() {
    getAuth().then((value) {
      if (value.value != null) {
        navigatorPushReplace(context, page: Dashboard());
      }
    });
  }

  login() async {
    try {
      var result = await fireDB.ref('user').get();
      var data = result.children.toList().where((item) {
        if ((item.value as dynamic)['username'] == username.text) {
          return true;
        }

        return false;
      });

      if (data.isEmpty) {
        notif(context, text: 'username tidak ditemukan', color: Colors.red);
      } else {
        for (var item in data) {
          if ((item.value as dynamic)['password'] == password.text) {
            SharedPreferences session = await SharedPreferences.getInstance();
            session.setString('auth', item.key.toString());

            notif(context, text: 'berhasil login', color: Colors.green);
            navigatorPushReplace(context, page: Dashboard());
            return true;
          }
        }

        notif(context, text: 'password salah', color: Colors.red);
      }
    } catch (e) {
      notif(context, text: e.toString(), color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: size.height * .45,
              width: size.width,
              color: cPrimary,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: size.height * .2),
                  Panel(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          'LOGIN',
                          style:
                              TextStyle(color: cPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40),
                        TextFormField(
                          controller: username,
                          decoration: InputDecoration(
                            hintText: 'Username anda',
                            label: Text('Username'),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password anda',
                            label: Text('Password'),
                          ),
                        ),
                        SizedBox(height: 40),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: cPrimary,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: login,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'LOGIN',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? register '),
                            GestureDetector(
                              onTap: () {
                                navigatorPushReplace(context, page: Register());
                              },
                              child: Text(
                                'disini',
                                style: TextStyle(color: cPrimary),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
