import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String _scannedCode = 'Scan QR Code';
  MobileScannerController cameraController = MobileScannerController();
  bool _cameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermissionGranted = status.isGranted;
    });
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission is required to scan QR codes.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Code Scanner',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
            iconSize: 32,
          ),
          IconButton(
            onPressed: () => cameraController.switchCamera(),
            iconSize: 32.0,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return Icon(Icons.camera_rear);
                }
              },
            ),
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: _cameraPermissionGranted
          ? Column(
              children: [
                Expanded(
                  flex: 4,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        debugPrint('Barcode found! ${barcode.rawValue}');
                        setState(() {
                          _scannedCode = barcode.rawValue ?? 'No data';
                        });
                        cameraController.stop();
                        _showScannedResult(
                          context,
                          barcode.rawValue ?? 'No data',
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      _scannedCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scannedCode = 'Scan a QR Code';
                      });
                      cameraController.start();
                    },
                    child: const Text('Scan Another QR Code'),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Veuillez accorder la permission de la caméra pour utiliser le scanner de code QR.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }

  void _showScannedResult(BuildContext context, String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Scanned'),
          content: SelectableText(
            result,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cameraController.start();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
