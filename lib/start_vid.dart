import 'dart:async';
  import 'dart:io';
  import 'package:path_provider/path_provider.dart';
  import 'package:firebase_ml_vision/firebase_ml_vision.dart';
  import 'package:camera/camera.dart';
  import 'package:flutter/material.dart';
  import 'package:path/path.dart' show join;
  //import 'package:video_player/video_player.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'package:flutter/services.dart';


  class TakeVid extends StatefulWidget {
    @override
    _TakeVidState createState() {
      return _TakeVidState();
    }
  }
  
  List<Rect> _faces;
  class _TakeVidState extends State<TakeVid> {
    CameraController controller;
    String videoPath;
  
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
      availableCameras()
          .then((availableCameras) {
        cameras = availableCameras;
  
        if (cameras.length > 0) {
          setState(() {
            selectedCameraIdx = 1;
          });
  
          _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
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

    void findBound() async
    {
      final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              'temp.png',
            );

    if(await File(path).exists()) {
      File(path).delete();
    }
    imageCache.clear();

    //await new Future.delayed(const Duration(seconds : 1));
    // Attempt to take a picture and log where it's been saved.
    await controller.takePicture(path);
    

    File image = File(path);
    final image1 = FirebaseVisionImage.fromFile(image);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image1);
    _faces = new List<Rect>();
    for (var i = 0; i < faces.length; i++) {
    _faces.add(faces[i].boundingBox);
    }
    
    
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

      findBound();
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
              onPressed: _onSwitchCamera,
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
      if (controller != null) {
        await controller.dispose();
      }
  
      controller = CameraController(cameraDescription, ResolutionPreset.high);
  
      // If the controller is updated then update the UI.
      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
  
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
  
      try {
        await controller.initialize();
      } on CameraException catch (e) {
        _showCameraException(e);
      }
  
      if (mounted) {
        setState(() {});
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
  
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}