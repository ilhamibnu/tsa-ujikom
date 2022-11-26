// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:ujikom/component/panel.dart';
import 'package:ujikom/layout/login.dart';
import 'package:ujikom/layout/profil.dart';
import 'package:ujikom/layout/user.dart';
import 'package:ujikom/rules/index.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController searchLocation = TextEditingController();

  String userNama = '';
  Position position = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  bool loading = false;
  String address = 'Tidak diketahui';

  @override
  void initState() {
    super.initState();
    getUser();
    getLocation();
  }

  void getUser() async {
    getAuth().then((value) {
      if (value == null) {
        navigatorPushReplace(context, page: Login());
      } else {
        setState(() {
          userNama = value.value['nama'];
        });
      }
    });
  }

  void goToLocation() async {
    var intent = AndroidIntent(
      action: 'action_view',
      data: 'google.navigation:q=${searchLocation.text}',
    );
    await intent.launch();
  }

  getLocation() async {
    setState(() {
      loading = true;
    });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      notif(context, text: 'service lokasi tidak tersedia', color: Colors.red);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        notif(context, text: 'Akses lokasi tidak diizinkan');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      notif(context, text: 'Akses lokasi tidak diizinkan secara permanen');
    }

    var location = await Geolocator.getCurrentPosition();
    var placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
    var place = placemarks[0];

    setState(() {
      position = location;
      loading = false;
      address =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Dashboard',
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Panel(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userNama,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cPrimary),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Semoga hari anda menyenangkan!',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Panel(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Koordinat:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(loading ? 'Memuat...' : "${position.latitude},${position.longitude}"),
                SizedBox(height: 20),
                Text(
                  'Alamat:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 5),
                Text(
                  loading ? 'Memuat...' : address,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Panel(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayo Pergi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: searchLocation,
                  decoration: InputDecoration(
                    hintText: 'Lokasi yang ingin kamu tuju',
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
                        onTap: goToLocation,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: Text(
                            'GO...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getLocation,
        child: Icon(
          Icons.place,
        ),
      ),
    );
  }
}

class Layout extends StatefulWidget {
  const Layout({
    Key? key,
    this.body,
    this.title,
    this.floatingActionButton,
  }) : super(key: key);

  final Widget? body;
  final String? title;
  final Widget? floatingActionButton;

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  String userUsername = '';
  String userNama = '';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    cekUser();
  }

  void cekUser() {
    getAuth().then((value) {
      if (value.value != null) {
        setState(() {
          userUsername = value.value['username'];
          userNama = value.value['nama'];
          userRole = value.value['role'];
        });
      }
    });
  }

  logout() async {
    SharedPreferences session = await SharedPreferences.getInstance();
    await session.clear();

    navigatorPushReplace(context, page: Login());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.toString()),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: size.height * .25,
            width: size.width,
            decoration: BoxDecoration(
              color: cPrimary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          widget.body as Widget,
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: cPrimary,
                      size: 30,
                    )
                  ],
                ),
              ),
              accountName: Text(userUsername),
              accountEmail: Text(userNama),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                navigatorPush(context, page: Dashboard());
              },
            ),
            userRole == '1'
                ? ListTile(
                    leading: Icon(Icons.supervisor_account),
                    title: Text('Data User'),
                    onTap: () {
                      navigatorPush(context, page: User());
                    },
                  )
                : SizedBox(),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profil'),
              onTap: () {
                navigatorPush(context, page: Profil());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      content: Text("Anda yakin akan logout?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            navigatorPop(context);
                          },
                          child: Text('BATAL'),
                        ),
                        TextButton(
                          onPressed: logout,
                          child: Text('LOGOUT'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
