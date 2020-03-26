import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Multipart Example',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Multipart Example Home '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  @override
  void initState() {
    super.initState();
    //this method will ask permission for camera and storage
    _checkPersmissions();
  }

  _checkPersmissions() async {
    PermissionStatus cameraPermission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (cameraPermission == 2) {
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.camera]);
      setState(() {});
    }
    PermissionStatus storagePermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (storagePermission == 2) {
    } else {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      setState(() {});
    }
  }

  _showAlertForImagePicker(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Choose an action"),
              content: Text(""),
              actions: <Widget>[
                FlatButton(
                  child: Text('Gallery'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.gallery);
                  },
                ),
                FlatButton(
                  child: Text('Camera'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    getImage(ImageSource.camera);
                  },
                )
              ],
            ));
  }

  Future getImage(ImageSource sourImage) async {
    var image = await ImagePicker.pickImage(source: sourImage);
    setState(() {
      _image = image;
      upload(_image);
    });
  }

  upload(File imageFile) async {
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path;
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    //   var sign_stream = new http.ByteStream(DelegatingStream.typed(sign_file.openRead()));
    // get file length
    var length = await imageFile.length();

    // use this header if required else do not use this
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer " + 'token_value'
    };

    // string to uri
    var uri = Uri.parse('BASE_URL' + "endpoint_here");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file, image is the key for file
    var multipartFileImage = new http.MultipartFile(
        'image', stream, length, //image is the key for file to send
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFileImage);

    //add headers
    request.headers.addAll(headers);

    //adding params
    request.fields['loginId'] = 'login_id';
    request.fields['fullname'] = 'Test';
    request.fields['phone'] = '1234568998';
    request.fields['address'] = ' 11,sect 11';
    request.fields['meetingWith'] = 'Teacher';
    request.fields['purpose'] = 'PTM';
    // send
    var response = await request.send();

    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select image from gallery or take photo to upload',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _showAlertForImagePicker(context, "Select image or take image"),
        tooltip: 'Pick or take photo',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
