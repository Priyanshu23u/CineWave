import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:movie_booking/service/database.dart';

class QrcodeScanner extends StatefulWidget {  
  const QrcodeScanner({Key? key}) : super(key: key);
  
  @override
  State<QrcodeScanner> createState() => _QrcodeScannerState();
}

class _QrcodeScannerState extends State<QrcodeScanner> {
  final MobileScannerController _cameraController = MobileScannerController();
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  bool isVerifying = false;
  
  @override
  void initState() {
    super.initState();
  }

  void _onDetect(BarcodeCapture capture) async {
    // Ignore if already verifying
    if (isVerifying) return;
    
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        
        // Stop the scanner while verifying
        _cameraController.stop();
        
        setState(() {
          isVerifying = true;
        });
        
        // Verify against database
        bool isValid = await _databaseMethods.verifyQRCode(code);
        
        setState(() {
          isVerifying = false;
        });
        
        // Show appropriate dialog
        if (isValid) {
          _showMatchDialog(code);
        } else {
          _showInvalidDialog(code);
        }
        
        break;
      }
    }
  }

  void _showMatchDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Verified'),
          content: Text('Valid QR Code: $code'),
          backgroundColor: Colors.green[50],
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and restart the scanner
                Navigator.of(context).pop();
                _cameraController.start();
              },
              child: const Text("Scan Again"),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and go back
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Done"),
            ),
          ]
        );
      },
    );
  }
  
  void _showInvalidDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid QR Code'),
          content: Text('The QR code "$code" is not recognized.'),
          backgroundColor: Colors.red[50],
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and restart the scanner
                Navigator.of(context).pop();
                _cameraController.start();
              },
              child: const Text("Try Again"),
            ),
          ]
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          if (isVerifying)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Verifying QR code...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Position QR code in the camera view",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}