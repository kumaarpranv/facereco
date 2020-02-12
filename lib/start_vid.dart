import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image/image.dart' as imglib;


  class TakeVid extends StatefulWidget {
    @override
    _TakeVidState createState() {
      return _TakeVidState();
    }
  }
  
  List<Rect> _faces;
  class _TakeVidState extends State<TakeVid> {
    CameraController controller;

  
    List<CameraDescription> cameras;
    int selectedCameraIdx;
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    


    @override
    void initState() {
      super.initState();
      _faces = new List<Rect>();
      //_faces.add(Rect.fromLTRB(50.0,100.0,140.0,200.0));
      // Get the listonNewCameraSelected of available cameras.
      // Then set the first camera as selected.
      if(controller != null)
      {
        controller.stopImageStream();
        controller.dispose();
      }

      availableCameras()
          .then((availableCameras) {
        cameras = availableCameras;
  
        if (cameras.length > 0) {
          setState(() {
            selectedCameraIdx = 1;
          });
  
          _onCameraSwitched(cameras[selectedCameraIdx]);
        }
      })

      
          .catchError((err) {
        print('Error: $err.code\nError Message: $err.message');
      });
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Detector'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: controller != null && controller.value.isRecordingVideo
                        ? Colors.redAccent
                        : Colors.grey,
                    width: 3.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _cameraTogglesRowWidget(),
                  Expanded(
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }


/*
Future<Image> convertImg(CameraImage image) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for(int x=0; x < width; x++) {
      for(int y=0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);     
        // color: 0x FF  FF  FF  FF 
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }

    imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(img);
    
    return Image.memory(png);  
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}


Future<List<int>> convertImgBytes(CameraImage image) async {
  try {
    imglib.Image img;
  img = imglib.Image(image.width, image.height); // Create Image buffer

  Plane plane = image.planes[0];
  const int shift = (0xFF << 24);

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < image.width; x++) {
    for (int planeOffset = 0;
        planeOffset < image.height * image.width;
        planeOffset += image.width) {
      final pixelColor = plane.bytes[planeOffset + x];
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      // Calculate pixel color
      var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

      img.data[planeOffset + x] = newVal;
    }
  }

    imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

    // Convert to png
    List<int> png = pngEncoder.encodeImage(img);
    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}
*/



    void findBound(CameraImage availableImage) async
    {
      

    //await new Future.delayed(const Duration(seconds : 1));
    // Attempt to take a picture and log where it's been saved.
    //await controller.takePicture(path);
   
    final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
      rawFormat: availableImage.format.raw,
      size: Size(availableImage.width.toDouble(),availableImage.height.toDouble()),
      planeData: availableImage.planes.map((currentPlane) => FirebaseVisionImagePlaneMetadata(
        bytesPerRow: currentPlane.bytesPerRow,
        height: currentPlane.height,
        width: currentPlane.width
        )).toList(),
      //rotation: ImageRotation.rotation90
      );
  
    //List<int> bt = await convertImgBytes(availableImage);

    
    final image1 =  FirebaseVisionImage.fromBytes(availableImage.planes[0].bytes, metadata);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image1);
    setState(() {
    _faces = new List<Rect>();  

    for (var i = 0; i < faces.length; i++) {
    _faces.add(faces[i].boundingBox);
    }
        });
    log('data: $_faces');
    
    }

    IconData _getCameraLensIcon(CameraLensDirection direction) {
      switch (direction) {
        case CameraLensDirection.back:
          return Icons.camera_rear;
        case CameraLensDirection.front:
          return Icons.camera_front;
        case CameraLensDirection.external:
          return Icons.camera;
        default:
          return Icons.device_unknown;
      }
    }
  
    // Display 'Loading' text when the camera is still loading.
    Widget _cameraPreviewWidget() {
      if (controller == null || !controller.value.isInitialized) {
        return const Text(
          'Loading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        );
      }

      //findBound();
      return new CustomPaint(
        foregroundPainter: new FacePainter(),
        child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ));
    }
  
    /// Display a row of toggle to select the camera (or a message if no camera is available).
    Widget _cameraTogglesRowWidget() {
      if (cameras == null) {
        return Row();
      }
  
      CameraDescription selectedCamera = cameras[selectedCameraIdx];
      CameraLensDirection lensDirection = selectedCamera.lensDirection;
  
      return Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: FlatButton.icon(
              onPressed: null,//_onSwitchCamera,
              icon: Icon(
                  _getCameraLensIcon(lensDirection)
              ),
              label: Text("${lensDirection.toString()
                  .substring(lensDirection.toString().indexOf('.')+1)}")
          ),
        ),
      );
    }
  
   
  
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
    Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
       
      if(controller != null)
      {
        controller.stopImageStream();
        controller.dispose();
      }
      
      controller = CameraController(cameraDescription, ResolutionPreset.medium, enableAudio: false);
      // If the controller is updated then update the UI.
      /*
      controller.addListener(() {
       
        if (controller.value.hasError) {
          Fluttertoast.showToast(
              msg: 'Camera error ${controller.value.errorDescription}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white
          );
        }
      });
      */
      try {
        controller.initialize().then((_){
            controller.startImageStream((CameraImage availableImage) {
         log('data: hello');
        findBound(availableImage);
          });
        });
         

      } on CameraException catch (e) {
        _showCameraException(e);
      }
      
      

      if (mounted) {
        setState(() {     
        });

      }
    }
  
    void _onSwitchCamera() {
      selectedCameraIdx = selectedCameraIdx < cameras.length - 1
          ? selectedCameraIdx + 1
          : 0;
      CameraDescription selectedCamera = cameras[selectedCameraIdx];
  
      _onCameraSwitched(selectedCamera);
  
      setState(() {
        selectedCameraIdx = selectedCameraIdx;
      });
    }
  
   
  
    void _showCameraException(CameraException e) {
      String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
      print(errorText);
  
      Fluttertoast.showToast(
          msg: 'Error: ${e.code}\n${e.description}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white
      );
    }
  }
  
  class VideoRecorderApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: TakeVid(),
      );
    }
  }
  
  Future<void> main() async {
    runApp(VideoRecorderApp());
  }


  class FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 3.0
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    //var path = new Path()..lineTo(50.0, 50.0);
    //canvas.drawPath(path, paint);
    for(int i=0;i<_faces.length;i++)
    canvas.drawRect(_faces[i], paint);
    
    //canvas.drawRect( new Rect.fromLTRB(100.0, 50.0, 200.0, 250.0), paint);//_faces[i], paint);
  
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}