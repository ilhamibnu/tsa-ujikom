// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ujikom/component/panel.dart';
import 'package:ujikom/layout/login.dart';
import 'package:ujikom/layout/user.dart';
import 'package:ujikom/rules/index.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseDatabase fireDB = FirebaseDatabase.instance;

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nama = TextEditingController();
  TextEditingController nomorTelepon = TextEditingController();

  register() async {
    try {
      var result = await fireDB.ref('user').get();
      var data = result.children.toList().where((item) {
        if ((item.value as dynamic)['username'] == username.text) {
          return true;
        }
        return false;
      });

      if (data.isEmpty) {
        await fireDB.ref('user').push().set({
          'username': username.text,
          'nama': nama.text,
          'password': password.text,
          'nomorTelepon': nomorTelepon.text,
          'role': '1',
        }).then((value) {
          notif(context,
              text: 'registrasi akun berhasil. silahkan login!',
              color: Colors.green);
          navigatorPushReplace(context, page: Login());
        });
      } else {
        notif(context, text: 'username sudah digunakan', color: Colors.red);
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
                  SizedBox(height: size.height * .15),
                  Panel(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          'REGISTER',
                          style: TextStyle(
                              color: cPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
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
                            hintText: '********',
                            label: Text('Password'),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: nama,
                          decoration: InputDecoration(
                            hintText: 'Nama anda',
                            label: Text('Nama'),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: nomorTelepon,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '62xxxxxxxxx',
                            label: Text('Nomor Telepon'),
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
                                onTap: register,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'REGISTER',
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
                            Text('Sudah punya akun? login '),
                            GestureDetector(
                              onTap: () {
                                navigatorPushReplace(context, page: Login());
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
