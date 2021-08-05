import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_sharedpref/DashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      home: new MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/DashboardScreen': (BuildContext context) => new DashboardScreen(),
        '/MyHomePage': (BuildContext context) => new MyHomePage(),
      },
    );
  }
}

class Items {
  String nama;
  String provinsi;

  Items({this.nama, this.provinsi});

  factory Items.fromJSON(Map<String, dynamic> json) {
    return Items(nama: json['Nama'], provinsi: json['Propinsi']);
  }
}

class UserData {
  List<Items> items;
  String token;
  String message;
  int code;

  UserData({this.items, this.token, this.message, this.code});

  factory UserData.fromJSON(Map<String, dynamic> json) {
    return UserData(
        items: List.from(json['data']['items'])
            .map((e) => Items.fromJSON(e))
            .toList(),
        token: json['data']['token'],
        message: json['message'],
        code: json['code']);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();

  String msg = '';
  String loginURL = "http://103.226.139.253:32258/v1/auth/loginpengguna";


  Future<UserData> _login() async {
    Map<String, String> formData = <String, String>{
      "email": "${user.text}",
      "password": "${pass.text}"
    };
    try {
      var request = http.MultipartRequest('POST', Uri.parse(loginURL));
      request.fields.addAll(formData);
      var response = await request.send();
      var respStr = await http.Response.fromStream(response);
      print("Response: ${respStr.body}");
      var datauser = json.decode(respStr.body);
      print("Data User: $datauser");
      return UserData.fromJSON(datauser);
    } catch (e) {
      print("Error adalah: $e");
      return UserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                "Username",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: user,
                decoration: InputDecoration(hintText: 'Username'),
              ),
              Text(
                "Password",
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
              ),
              RaisedButton(
                child: Text("Login"),
                onPressed: () {
                  _login().then((value) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    if (value.code == 0) {
                      await prefs.setString('token', value.token);
                      await prefs.setString('nama', value.items.first.nama);
                      await prefs.setString(
                          'provinsi', value.items.first.provinsi);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DashboardScreen()));
                    } else {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                            'Silahkan masukkan email dan pasword dengan benar'),
                      ));
                    }
                  });
                  //     .whenComplete(() {
                  //
                  // });
                },
              ),
              Text(
                msg,
                style: TextStyle(fontSize: 20.0, color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }
}
