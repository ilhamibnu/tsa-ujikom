// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ujikom/component/panel.dart';
import 'package:ujikom/layout/dashboard.dart';
import 'package:ujikom/rules/index.dart';

class User extends StatefulWidget {
  User({Key? key}) : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  FirebaseDatabase fireDB = FirebaseDatabase.instance;

  bool loading = false;
  List data = [];

  TextEditingController username = TextEditingController();
  TextEditingController nama = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nomorTelepon = TextEditingController();

  @override
  void initState() {
    super.initState();
    get();
  }

  nullable() {
    setState(() {
      username.text = '';
      nama.text = '';
      password.text = '';
      nomorTelepon.text = '';
    });
  }

  Future get() async {
    nullable();
    setState(() {
      loading = true;
    });
    var result = await fireDB.ref('user').get();
    print(result);
    setState(() {
      data = result.children.toList();
      loading = false;
    });
  }

  Future store() async {
    try {
      await fireDB.ref('user').push().set({
        'username': username.text,
        'nama': nama.text,
        'password': password.text,
        'nomorTelepon': nomorTelepon.text,
        'role': '2',
      }).then((value) async {
        notif(context, text: 'data berhasil ditambah', color: Colors.green);
        get();
      });
    } catch (e) {
      notif(context, text: e.toString(), color: Colors.red);
    }
  }

  Future update(key) async {
    try {
      var data = {
        'username': username.text,
        'nama': nama.text,
        'nomorTelepon': nomorTelepon.text,
        'role': '2',
      };

      if (password.text.isNotEmpty) {
        data['password'] = password.text;
      }

      await fireDB.ref('user').child(key).update(data).then((value) {
        notif(context, text: 'data berhasil diedit', color: Colors.green);
        get();
      });
    } catch (e) {
      notif(context, text: e.toString(), color: Colors.red);
    }
  }

  Future destroy(key) async {
    try {
      await fireDB.ref('user').child(key).remove().then((value) {
        notif(context, text: 'data berhasil dihapus', color: Colors.green);
        get();
      });
    } catch (e) {
      notif(context, text: e.toString(), color: Colors.red);
    }
  }

  void showForm({dynamic key}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          // margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${key != null ? 'Edit' : 'Tambah'} User',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
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
                obscureText: true,
                decoration: InputDecoration(
                    hintText:
                        key != null ? 'Kosongkan jika tidak ingin mengganti password' : '******',
                    label: Text('Password')),
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
                          var result = key != null ? update(key) : store();
                          result.then((value) {
                            navigatorPop(context);
                          });
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
              SizedBox(height: 20),
            ],
          ),
        );
      },
      // isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Data User',
      body: loading
          ? Center(
              child: Text('Memuat...'),
            )
          : data.isEmpty
              ? Center(
                  child: Text('data tidak tersedia'),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: data.length,
                  itemBuilder: (ctx, index) {
                    var item = data[index];

                    return Panel(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          ItemChild('Username', item.value['username']),
                          ItemChild('Nama', item.value['nama']),
                          ItemChild('Nomor Telepon', item.value['nomorTelepon']),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    username.text = item.value['username'];
                                    nama.text = item.value['nama'];
                                    password.text = '';
                                    nomorTelepon.text = item.value['nomorTelepon'];
                                  });
                                  showForm(key: item.key);
                                },
                                icon: Icon(Icons.edit),
                                color: cPrimary,
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          content:
                                              Text("Anda yakin menghapus ${item.value['nama']}?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                navigatorPop(context);
                                              },
                                              child: Text('BATAL'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                destroy(item.key).then((value) {
                                                  navigatorPop(context);
                                                });
                                              },
                                              child: Text('HAPUS'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nullable();
          showForm();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Column ItemChild(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
