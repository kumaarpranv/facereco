import 'dart:async';
import 'package:facereco/get_picture.dart';
import 'package:flutter/material.dart';
import 'start_vid.dart';
//import 'temp_stateful.dart';

Future<void> main() async {
  
  runApp(MaterialApp(
    title: 'home',
    //home: MyApp(),//TakePictureScreen(),//MyApp(),
    initialRoute: '/',
  routes: {
  
    '/': (context) => MyApp(),
    '/start':(context) => TakeVid(),//TakeVid(),
    '/add': (context) => GetPictureScreen()//TakePictureScreen(),
    //'/display':(context) => DisplayPictureScreen()
  },
  ));
}

class MyApp extends StatelessWidget {

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Face Recognition App')),
        body: Center(
          child: 
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: 100.0,
                horizontal: 0,
              ),
              child:
          Column( 
            children: <Widget>
            [ 
              
            RaisedButton(
            child: const Text('start', style: TextStyle(fontSize: 20, color: Colors.white)),
            color: Colors.blue,
            onPressed: () {
             //Navigator.push(context, MaterialPageRoute(builder: (context) async => TakePictureScreen()));
            
            Navigator.pushNamed(context, '/start');
            },
            )  
            ,
            RaisedButton(
            child: const Text('add', style: TextStyle(fontSize: 20, color: Colors.white)),
            color: Colors.blue,
            onPressed: () {
             //Navigator.push(context, MaterialPageRoute(builder: (context) async => TakePictureScreen()));
            
            Navigator.pushNamed(context, '/add');
            },
            )
           ]
          )
        ) 
        )
        );
     
    
}

}


