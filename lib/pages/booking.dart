import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/service/database.dart';
import 'package:movie_booking/service/shared_pref.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? id, name;
  Stream? bookingStream;

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserDisplayName();
    setState(() {});
  }

  getontheload() async {
    await getthesharedpref();
    bookingStream = await DatabaseMethods().getbookings(id!);
    setState(() {});
  }

  // Function to navigate to the QrcodeScanner screen
  void navigateToScanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrcodeScanner()),
    );
  }

  Widget allBooking() {
    return StreamBuilder(
        stream: bookingStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: LayoutBuilder(builder: (context, constraints) {
                        // Check if the width is for a small device
                        bool isSmallScreen = constraints.maxWidth < 600;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            QrImageView(
                              data: ds["QrId"],
                              version: QrVersions.auto,
                              size: isSmallScreen ? 120 : 150,
                            ),
                            SizedBox(height: 15),
                            isSmallScreen
                                ? _buildSmallScreenLayout(ds)
                                : _buildWideScreenLayout(ds),
                            SizedBox(height: 10),
                          ],
                        );
                      }),
                    );
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  // Layout for small screens (stacked vertically)
  Widget _buildSmallScreenLayout(DocumentSnapshot ds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'images/infinity.jpg',
            height: 120,
            width: 120,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 15),
        _buildBookingDetails(ds, isCompact: true),
      ],
    );
  }

  // Layout for wide screens (horizontal layout)
  Widget _buildWideScreenLayout(DocumentSnapshot ds) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'images/infinity.jpg',
            height: 130,
            width: 130,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 20),
        Expanded(child: _buildBookingDetails(ds, isCompact: false)),
      ],
    );
  }

  // Common booking details content
  Widget _buildBookingDetails(DocumentSnapshot ds, {required bool isCompact}) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: isCompact ? 18 : 22,
      fontWeight: FontWeight.w500,
    );

    final titleStyle = TextStyle(
      color: Colors.black,
      fontSize: isCompact ? 20 : 22,
      fontWeight: FontWeight.w500,
    );

    final movieStyle = TextStyle(
      color: Colors.black54,
      fontSize: isCompact ? 18 : 22,
      fontWeight: FontWeight.w500,
    );

    final valueStyle = TextStyle(
      color: Colors.black,
      fontSize: isCompact ? 18 : 22,
      fontWeight: FontWeight.bold,
    );

    final iconColor = Color.fromARGB(255, 204, 151, 7);
    final iconSize = isCompact ? 18.0 : 24.0;

    return Column(
      crossAxisAlignment:
          isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.person,
          ds["Name"],
          iconColor: iconColor,
          textStyle: titleStyle,
          iconSize: iconSize,
          isCompact: isCompact,
        ),
        SizedBox(height: 5),
        _buildInfoRow(
          Icons.movie,
          ds["Movie"],
          iconColor: iconColor,
          textStyle: movieStyle,
          iconSize: iconSize,
          isCompact: isCompact,
        ),
        SizedBox(height: 8),
        Wrap(
          alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
          spacing: 15,
          runSpacing: 8,
          children: [
            _buildCompactInfo(
              Icons.group,
              ds["Quantity"],
              iconColor: iconColor,
              textStyle: valueStyle,
              iconSize: iconSize,
            ),
            _buildCompactInfo(
              Icons.monetization_on,
              "\$" + ds["Total"],
              iconColor: iconColor,
              textStyle: valueStyle,
              iconSize: iconSize,
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
          spacing: 15,
          runSpacing: 8,
          children: [
            _buildCompactInfo(
              Icons.alarm,
              ds["Time"],
              iconColor: iconColor,
              textStyle: valueStyle,
              iconSize: iconSize,
            ),
            _buildCompactInfo(
              Icons.calendar_month,
              ds["Date"],
              iconColor: iconColor,
              textStyle: valueStyle,
              iconSize: iconSize,
            ),
          ],
        ),
      ],
    );
  }

  // Helper method for regular info rows
  Widget _buildInfoRow(
    IconData icon,
    String text, {
    required Color iconColor,
    required TextStyle textStyle,
    required double iconSize,
    required bool isCompact,
  }) {
    return Row(
      mainAxisAlignment:
          isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            textAlign: isCompact ? TextAlign.center : TextAlign.start,
          ),
        )
      ],
    );
  }

  // Helper method for compact info items
  Widget _buildCompactInfo(
    IconData icon,
    String text, {
    required Color iconColor,
    required TextStyle textStyle,
    required double iconSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: 5),
        Text(text, style: textStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor:
          themeMode == Brightness.dark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bookings",
                      style: TextStyle(
                        color: themeMode == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Scan QR Button (Changed from Verify QR)
                    ElevatedButton.icon(
                      onPressed: navigateToScanQR,
                      icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: Text(
                        "Scan QR",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffedb41d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 15, top: 20, right: 15),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff1e232c),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await getontheload();
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          allBooking(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Import and use the existing QrcodeScanner from qrcode_scanner.dart
class QrcodeScanner extends StatefulWidget {  
  const QrcodeScanner({Key? key}) : super(key: key);
  
  @override
  State<QrcodeScanner> createState() => _QrcodeScannerState();
}

// This is a placeholder to avoid compilation errors.
// In your actual code, you'll use the imported QrcodeScanner class
class _QrcodeScannerState extends State<QrcodeScanner> {
  @override
  Widget build(BuildContext context) {
    // This won't actually be used since you'll import the real QrcodeScanner
    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner')),
      body: Center(child: Text('QR Scanner')),
    );
  }
}