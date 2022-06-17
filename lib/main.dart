import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:simple_pip_mode/simple_pip.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              child: ElevatedButton(
                onPressed: () {
                  SimplePip()
                      .enterPipMode(aspectRatio: [3, 2], autoEnter: false);
                },
                child: const Text("Float Mode",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   // Provide an onPressed callback.
      //   onPressed: () async {
      //     try {
      //       SimplePip().enterPipMode(
      //         aspectRatio: [3, 2],
      //       );
      //       // await _initializeControllerFuture;
      //       //
      //       //
      //       // final image = await _controller.takePicture();
      //       //
      //       //
      //       // await Navigator.of(context).push(
      //       //   MaterialPageRoute(
      //       //     builder: (context) => DisplayPictureScreen(
      //       //       imagePath: image.path,
      //       //     ),
      //       //   ),
      //       // );
      //     } catch (e) {
      //       // If an error occurs, log the error to the console.
      //       print(e);
      //     }
      //   },
      //   child: const Icon(Icons.camera_alt),
      // ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.file(File(imagePath)),
    );
  }
}
