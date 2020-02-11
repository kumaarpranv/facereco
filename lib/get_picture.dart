import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
List<List<double>> allbounds;
List<int> facebnd;
class GetPictureScreen extends StatefulWidget
{
    const GetPictureScreen({
    Key key,
  }) : super(key: key);

  @override
  GetPictureScreenState createState() => GetPictureScreenState();

}
class GetPictureScreenState extends State<GetPictureScreen> {
  
  List<File> imgs;
  int count;
  final List<String> tips=['pick front','pick top','pick bottom','pick left','pick right'];
  String tip;
  //var _faces;
  //ui.Image _uiimg;
  Image _uiimg;
  @override
  void initState() {
   
    super.initState();
    imgs=List<File>();
    count = 0;
    tip = tips[count];
    allbounds=List<List<double>>();
     facebnd=List<int>();
    //_faces=null;
    _uiimg = null;
  }

 

  Future getImage() async {
    if(count<5)
    {
      var image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 750); //imageQuality: 50
     //List bytes=await image.readAsBytes();
  
    final image1 = FirebaseVisionImage.fromFile(image);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image1);
    for (var i = 0; i < faces.length; i++) {
    allbounds.add([faces[i].boundingBox.top,faces[i].boundingBox.top,faces[i].boundingBox.bottom,faces[i].boundingBox.left,faces[i].boundingBox.right]);
    }
    if(faces.length == null)
    facebnd.add(0);
    else 
    facebnd.add(faces.length);
    
    imgs.add(image);
    count+=1;
    setState(() {
   //_faces = faces;
   /*
    ui.decodeImageFromList(bytes,(img){
       _uiimg = img;
    });
  */
  _uiimg = Image.file(image);
  if(count <= 4)
    tip = tips[count]; 

    });

    if(count == 5)
    Navigator.push(
                context,
                
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(images: imgs),
                ),
              );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
      ),
      body: 
      Center(
      child:
        _uiimg == null
            ? Text('No image selected.')
            : //Container( child: Image.file(_image))
            Center(
                  child: FittedBox(
                    child: SizedBox(
                      width: 550, //_uiimg.width.toDouble(),
                      height: 800,//_uiimg.height.toDouble(),
                      /*
                      child: CustomPaint(
                        painter: FacePainter(_uiimg, _faces),
                      ),
                      */
                      child: 
                          Container( child: _uiimg)
                    ),
                  ),
                )
      )
      ,
      floatingActionButton: 
       Stack(   
        children: <Widget>[ 
      Align(alignment: FractionalOffset.bottomCenter,
          child: Text( tip, style: TextStyle(fontSize: 20,color: Colors.black),)
          )
          ,
           Align(
            alignment: Alignment.bottomRight,
            child:FloatingActionButton(
        onPressed: getImage,
        tooltip: tip,
        child: Icon(Icons.add_a_photo),
      ),
           )
        ])
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
final List<File> images;

  const DisplayPictureScreen({Key key, this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //debugPrint('data: $imagePaths');
    return Scaffold(
      appBar: AppBar(title: Text('Display')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      //body: Image.file(File(imagePath)),
      body: Stack( 
        children://Image.file(File(imagePaths[0])),
      <Widget>[ new GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
          padding: const EdgeInsets.all(3.0),
          mainAxisSpacing: 3.0,
          crossAxisSpacing: 3.0,
        children: new List<Widget>.generate(images.length, (index) {
          return new GridTile(
            child: Image.file(images[index]),
            
          );
        }), 
        ),

      Align(alignment: FractionalOffset.bottomCenter,
          child: RaisedButton(color: Colors.blue, child: Text("Upload", style: TextStyle(color: Colors.white, fontSize: 20)),
              onPressed: (){

              },
          ),
          )
  
        ]
      )
    );
  }

}


class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];
  List<double> facebounds=[];
  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);

      /*
      facebounds.add(faces[i].boundingBox.top);
      facebounds.add(faces[i].boundingBox.bottom);
      facebounds.add(faces[i].boundingBox.left);
      facebounds.add(faces[i].boundingBox.right);
      allbounds.add(facebounds);
       */
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }


  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
