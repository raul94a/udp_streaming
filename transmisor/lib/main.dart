import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LaunchScreen());
  }
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.text = '192.168.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  hintText: 'Introduce la IP del monitor',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      borderSide: const BorderSide(color: Colors.grey))),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () async {
                  final monitorIp = controller.text;
                  RawDatagramSocket.bind(InternetAddress.anyIPv4, 16001)
                      .then((socket) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            CameraApp(socket: socket, monitorIp: monitorIp)));
                  });
                },
                child: const Text('Continuar'))
          ],
        ),
      ),
    );
  }
}
