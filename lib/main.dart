import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_sharedpref/DashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

String username='';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login PHP My Admin',
      home: new MyHomePage(),
      routes: <String,WidgetBuilder>{
        '/MemberPage': (BuildContext context)=> new DashboardScreen(),
        '/MyHomePage': (BuildContext context)=> new MyHomePage(),
      },
    );
  }
}
class Items {
  String nama;
  String provinsi;

  Items({this.nama, this.provinsi});
}
class UserData {
  List<Items> items;
  String token;

  UserData({this.items, this.token});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController user=new TextEditingController();
  TextEditingController pass=new TextEditingController();

  String msg='';
  String loginURL="103.226.139.253:32258/v1/auth/loginpengguna";
  UserData userData = UserData();
  List<Items> item = <Items>[];

  Future<UserData> _login() async {
    Map<String, String> formData = <String, String>{
      "email" : "${user.text}",
      "password" : "${pass.text}"
    };
    var request = http.MultipartRequest('POST', Uri.parse(loginURL));
    request.fields.addAll(formData);
    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    var datauser = json.decode(respStr);

    userData.token = datauser['data']['token'];
    item = datauser['data']['items'];
    userData.items = item;
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Username",style: TextStyle(fontSize: 18.0),),
              TextField(
                controller: user,
                decoration: InputDecoration(
                    hintText: 'Username'
                ),
              ),
              Text("Password",style: TextStyle(fontSize: 18.0),),
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: 'Password'
                ),
              ),

              RaisedButton(
                child: Text("Login"),
                onPressed: (){
                  _login().then((value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('token', value.token);
                    await prefs.setString('nama', value.items.first.nama);
                    await prefs.setString('provinsi', value.items.first.provinsi);
                  }).whenComplete(() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DashboardScreen()
                    ));
                  });
                },
              ),

              Text(msg,style: TextStyle(fontSize: 20.0,color: Colors.red),)


            ],
          ),
        ),
      ),
    );
  }
}