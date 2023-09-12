import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const StreamingVideo());
  }
}

class StreamingVideo extends StatefulWidget {
  const StreamingVideo({super.key, this.ip});
  final String? ip;

  @override
  State<StreamingVideo> createState() => _StreamingVideoState();
}

class _StreamingVideoState extends State<StreamingVideo> {
  late RawDatagramSocket socket;
  late ServerSocket tcpSocket;
  final StreamController<List<int>> cnt = StreamController();

  @override
  void initState() {
    super.initState();

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 16001).then((value) {
      socket = value;
      socket.listen((event) {
        print('Receiving event: $event');
        socket.broadcastEnabled = true;
        final datagram = socket.receive();

        if (datagram != null) {
          cnt.add(datagram.data);
        }
      });
    }, onError: (err) => print('error: $err'));
  }

  List<int> bytesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<List<int>>(
            stream: cnt.stream,
            builder: (ctx, snapshot) {
              final bytes = Uint8List.fromList(snapshot.data ?? []);
              if (bytes.isEmpty) {
                return const Center();
              }
              return Center(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.memory(
                    bytes,
                   
                    fit: BoxFit.fill,
                             
                    gaplessPlayback: true,
                  ),
                ),
              );
            }));
  }
}
