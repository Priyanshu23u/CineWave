import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_booking/service/database.dart';

class Verifyqr extends StatefulWidget {
  const Verifyqr({super.key});

  @override
  State<Verifyqr> createState() => _VerifyqrState();
}

class _VerifyqrState extends State<Verifyqr> {
  bool isScanning = false;
  MobileScannerController? scannerController;
  String scanResult = "";
  bool isVerified = false;
  bool isVerifying = false;
  bool cameraInitialized = false;
  
  // Database methods instance
  final DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cleanupScanner();
    super.dispose();
  }
  
  void _cleanupScanner() {
    if (scannerController != null) {
      scannerController!.stop();
      scannerController!.dispose();
      scannerController = null;
    }
  }
  
  // Start scanning QR code
  void _startScan() {
    // Make sure we clean up any existing controller first
    _cleanupScanner();
    
    // Create a new controller
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    
    setState(() {
      isScanning = true;
      cameraInitialized = false;
      isVerified = false;
      isVerifying = false;
      scanResult = "";
    });
    
    // Add a small delay to ensure the controller is properly initialized
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && scannerController != null) {
        setState(() {
          cameraInitialized = true;
        });
        scannerController!.start();
      }
    });
  }
  
  // Stop scanning
  void _stopScan() {
    _cleanupScanner();
    setState(() {
      isScanning = false;
      cameraInitialized = false;
    });
  }

  // Verify if QR code exists in Firestore database
  Future<bool> verifyQRCode(String qrData) async {
    try {
      return await _databaseMethods.verifyQRCode(qrData);
    } catch (e) {
      print("Error verifying QR code: $e");
      return false;
    }
  }
  
  // Show verification result dialog
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isVerified ? "QR Code Verified" : "Invalid QR Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isVerified 
                ? "The QR code is valid and present in the database."
                : "The QR code is not recognized. Please try again with a valid QR code."),
            SizedBox(height: 8),
            Text("Scanned code: $scanResult", 
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
        backgroundColor: isVerified ? Colors.green[50] : Colors.red[50],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isVerified) {
                // If verified, close scanner and go back to initial state
                _stopScan();
              } else if (scannerController != null) {
                // If not verified and controller exists, resume scanning
                scannerController!.start();
              }
            },
            child: Text(isVerified ? "OK" : "Try Again"),
          ),
        ],
      ),
    );
  }
  
  // QR Scanner view
  Widget _buildQrView(BuildContext context) {
    return Stack(
      children: [
        if (scannerController != null)
          MobileScanner(
            controller: scannerController!,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !isVerifying) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  // Pause scanning during verification
                  if (scannerController != null) {
                    scannerController!.stop();
                  }
                  
                  setState(() {
                    isVerifying = true;
                    scanResult = code;
                  });
                  
                  // Verify QR code against database
                  bool isValid = await verifyQRCode(code);
                  
                  if (mounted) {
                    setState(() {
                      isVerified = isValid;
                      isVerifying = false;
                    });
                    
                    // Show result dialog
                    _showResultDialog();
                  }
                }
              }
            },
          ),
        if (!cameraInitialized)
          Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: _stopScan,
            ),
          ),
        ),
        if (isScanning)
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
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("QR Code Verification"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            if (!isScanning) 
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/qr-code.png",
                        height: 250,
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Scan QR codes to verify their authenticity",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: _buildQrView(context),
                ),
              ),
            if (isVerifying)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Verifying QR code..."),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: GestureDetector(
                onTap: () {
                  if (!isScanning) {
                    _startScan();
                  } else {
                    _stopScan();
                  }
                },
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 250,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        isScanning ? "Cancel Scanning" : "Scan QR Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}