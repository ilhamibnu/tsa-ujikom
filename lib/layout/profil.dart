// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom/component/panel.dart';
import 'package:ujikom/layout/dashboard.dart';
import 'package:ujikom/rules/index.dart';

class Profil extends StatefulWidget {
  Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  FirebaseDatabase fireDB = FirebaseDatabase.instance;

  TextEditingController username = TextEditingController();
  TextEditingController nama = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nomorTelepon = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    await getAuth().then((value) {
      setState(() {
        username.text = value.value['username'];
        nama.text = value.value['nama'];
        password.text = '';
        nomorTelepon.text = value.value['nomorTelepon'];
      });
    });
  }

  Future update() async {
    SharedPreferences session = await SharedPreferences.getInstance();
    String key = session.getString('auth').toString();

    try {
      var data = {
        'username': username.text,
        'nama': nama.text,
        'nomorTelepon': nomorTelepon.text,
      };

      if (password.text.isNotEmpty) {
        data['password'] = password.text;
      }

      await fireDB.ref('user').child(key).update(data).then((value) {
        notif(context, text: 'akun berhasil diedit', color: Colors.green);
        getUser();
      });
    } catch (e) {
      notif(context, text: e.toString(), color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Profil',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Panel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: username,
                decoration: InputDecoration(hintText: 'Masukkan Username', label: Text('Username')),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nama,
                decoration: InputDecoration(hintText: 'Masukkan Nama', label: Text('Nama')),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: password,
                // obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Kosongkan jika tidak ingin mengganti password',
                  label: Text('Password'),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nomorTelepon,
                keyboardType: TextInputType.phone,
                decoration:
                    InputDecoration(hintText: '62xxxxxxxxxxx', label: Text('Nomor Telepon')),
              ),
              SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: cPrimary,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        try {
                          update();
                        } catch (e) {
                          notif(context, text: e.toString(), color: Colors.red);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: Text(
                          'SIMPAN',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
