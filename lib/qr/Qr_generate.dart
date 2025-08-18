import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:qr_flutter/qr_flutter.dart';

class QrGenerate extends StatefulWidget {
  const QrGenerate({super.key});

  @override
  State<QrGenerate> createState() => _QrGenerateState();
}

class _QrGenerateState extends State<QrGenerate> {
  final TextEditingController _textControler = TextEditingController(text: "");
  String data = '';
  final GlobalKey _qrkey = GlobalKey();
  bool dirExists = false;
  dynamic externalDir = '/Storage/emulated/0/Download/QR_Code';

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary =
          _qrkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      final whitePaint = Paint()..color = Colors.white;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          whitePaint);
      canvas.drawImage(image, Offset.zero, Paint());
      final picture = recorder.endRecording();
      final img = await picture.toImage(image.width, image.height);
      ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      String fileName = 'qr_code';
      int i = 1;
      while (await File('$externalDir/$fileName').exists()) {
        fileName = 'qr_code_$i';
        i++;
      }

      dirExists = await File(externalDir).exists();
      if (!dirExists) {
        await Directory(externalDir).create(recursive: true);
        dirExists = true;
      }

      final file = await File('$externalDir/$fileName.png').create();
      await file.writeAsBytes(pngBytes);
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('QR CODE saved to gallery '));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('Something went wrong !!! '));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    _textControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generator"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextField(
                controller: _textControler,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  labelText: 'Entrer Text',
                  labelStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 146, 20),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            RawMaterialButton(
              onPressed: () {
                data = _textControler.text;
              },
              shape: StadiumBorder(),
              padding:
                  EdgeInsetsGeometry.symmetric(horizontal: 36, vertical: 16),
              child: Text(
                "Generate",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: RepaintBoundary(
                key: _qrkey,
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: true,
                  errorStateBuilder: (ctx, err) {
                    return Center(
                      child: Text(
                        "Something went wrong !!!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
            RawMaterialButton(
              onPressed: _captureAndSavePng,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 16,
              ),
              child: Text(
                'Export',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
