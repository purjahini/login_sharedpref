import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {

  DashboardScreen();
  String nama;
  String provinsi;
  String token;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  void accessSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.nama = prefs.getString('nama');
      widget.provinsi = prefs.getString('provinsi');
      widget.token = prefs.getString('token');
    });
  }

  @override
  void initState() {
    super.initState();
    accessSharedPref();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${widget.nama}"),),
      body: Column(
        children: <Widget>[
          Text('Halo ${widget.nama}', style: TextStyle(fontSize: 20.0)),
          Text('dari Provinsi: ${widget.provinsi}', style: TextStyle(fontSize: 20.0)),
          Text('Tokenmu: ${widget.token}', style: TextStyle(fontSize: 20.0)),
          RaisedButton(
            child: Text("LogOUt"),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('nama');
              await prefs.remove('provinsi');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}