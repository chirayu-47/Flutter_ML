import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  themeMode: ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: MyApp(),
));


final lightTheme = ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.greenAccent,
        bottomAppBarColor: Colors.greenAccent,
        hintColor: Colors.yellowAccent,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.white,
          ),
        ),
      );


final darkTheme = ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.blueAccent,
        hintColor: Colors.deepOrangeAccent,
        bottomAppBarColor: Colors.grey,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.white,
          ),
        ),
      );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child:Scaffold(
        appBar: AppBar(
          title: const Text('Dog and Cat Classification'),
          centerTitle: true,
          bottom: TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.home),text: "Home",),
              Tab(icon: Icon(Icons.info_outlined),text: "About",),
              Tab(icon: Icon(Icons.settings),text: "Settings",)
            ],
          ), 
        ),
        bottomNavigationBar: BottomAppBar(notchMargin: 2.0,shape: CircularNotchedRectangle(),child: Container(height: 60.0,color: Colors.blueAccent,)),
        body: _loading
            ? Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
            : Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null ?  Text("Select an Image", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),): Image.file(_image),
              SizedBox(
                height: 20,
              ),
              _outputs != null
                  ? Text(
                "${_outputs[0]["label"]}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  background: Paint()..color = Colors.white,
                ),
              )
                  : Container()
            ],
          ),
        ),
       /* floatingActionButton: FloatingActionButton(
          onPressed: pickImage,
          child: Icon(Icons.image),
        ),*/
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton:
           SpeedDial(
            curve: Curves.bounceInOut,
            icon: Icons.add,
            activeIcon: Icons.close,
            spacing: 15,
            //animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                child: Icon(Icons.add_photo_alternate),
                label: "Add Image",
                onTap: pickImage
              ),
              SpeedDialChild(
                child: Icon(Icons.add_a_photo),
                label: "Camera",
                onTap: pickImageCamera
              )
            ],
          ),
      )
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

    pickImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}