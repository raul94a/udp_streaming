import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_compression/image_compression_io.dart' as iocompress;
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> cameras;

class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key, required this.socket, required this.monitorIp});

  final RawDatagramSocket socket;
  final String monitorIp;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late CameraImage cameraImage;
  bool canSendImage = true;
  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() {
    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});

      controller.startImageStream((image) {
        if (canSendImage) {
          sendImageToSocket(image);
        }
      });
    }).catchError((Object e) {
      debugPrint('$e');
    });
  }

  void sendImageToSocket(CameraImage cameraImage) async {
    canSendImage = false;
    final jpegBytes = await _getJpegBytes(cameraImage);
    compressAndStreamImage(jpegBytes);
  }

  Future<Uint8List> _getJpegBytes(CameraImage image) async {
    var image = await _convertBGRA8888(cameraImage);
    final jpegBytes = Uint8List.fromList(img.encodeJpg(image));
    return jpegBytes;
  }

  Future<img.Image> _convertBGRA8888(CameraImage image) async {
    final data = img.Image.fromBytes(
      width: image.planes[0].bytesPerRow ~/ 4,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
    return data;
  }

  void compressAndStreamImage(Uint8List jpegBytes) async {
    final input = iocompress.ImageFile(
      rawBytes: jpegBytes,
      filePath: '${(await getApplicationDocumentsDirectory()).path}/pic.jpg',
    );

    iocompress
        .compressInQueue(iocompress.ImageFileConfiguration(
          input: input,
        ))
        .then(_sendBytesToSocket);
  }

  void _sendBytesToSocket(iocompress.ImageFile output) {
    final bytes = output.rawBytes;
    print('List size: ${bytes.length}');
    final address = InternetAddress(widget.monitorIp);
    const port = 16001;
    widget.socket.send(bytes, address, port);

    canSendImage = true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller),
    );
  }
}
