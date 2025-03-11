import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingHistoryPage extends StatefulWidget {
  final String userId;

  const BookingHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> pastBookings = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getPastBookings();
  }

  Future<void> getPastBookings() async {
    if (widget.userId.isEmpty) {
      setState(() {
        errorMessage = "User ID not found. Please log in again.";
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get current date
      DateTime now = DateTime.now();
      String today = DateTime(now.year, now.month, now.day).toString().substring(0, 10);

      // Fetch past bookings (before today)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('Booking')
          .where('Date', isLessThan: today)
          .orderBy('Date', descending: true)
          .get();

      print("Found ${snapshot.docs.length} past booking documents");

      List<Map<String, dynamic>> bookingsData = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        bookingsData.add({
          'id': doc.id,
          ...data,
        });
      }

      setState(() {
        pastBookings = bookingsData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching past bookings: $e");
      setState(() {
        errorMessage = "Failed to load booking history. Please try again.";
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        
        final date = DateTime(year, month, day);
        return DateFormat.yMMMMd().format(date); // Returns "April 27, 2023"
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: themeMode == Brightness.dark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Booking History",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            ),
            onPressed: getPastBookings,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xffedb41d),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: screenWidth * 0.15,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        ElevatedButton(
                          onPressed: getPastBookings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffedb41d),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : pastBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_filter,
                            color: themeMode == Brightness.dark ? Colors.white38 : Colors.black38,
                            size: screenWidth * 0.2,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            "No past bookings found",
                            style: TextStyle(
                              color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                            child: Text(
                              "Your previous movie tickets will appear here once you've watched them",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: themeMode == Brightness.dark ? Colors.white70 : Colors.black54,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: ListView.builder(
                        itemCount: pastBookings.length,
                        itemBuilder: (context, index) {
                          final booking = pastBookings[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            decoration: BoxDecoration(
                              color: themeMode == Brightness.dark
                                  ? const Color(0xff1D1D2C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Movie poster
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                  child: Image.asset(
                                    booking['MovieImage'] ?? "images/infinity.jpg",
                                    width: screenWidth * 0.25,
                                    height: screenHeight * 0.15,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Booking details
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking['Movie'] ?? "Unknown Movie",
                                          style: TextStyle(
                                            color: themeMode == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: screenWidth * 0.04,
                                              color: themeMode == Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            Text(
                                              formatDate(booking['Date'] ?? 'Unknown Date'),
                                              style: TextStyle(
                                                color: themeMode == Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: screenWidth * 0.04,
                                              color: themeMode == Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            Text(
                                              booking['Time'] ?? 'Unknown Time',
                                              style: TextStyle(
                                                color: themeMode == Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.confirmation_number,
                                                  size: screenWidth * 0.04,
                                                  color: const Color(0xffedb41d),
                                                ),
                                                SizedBox(width: screenWidth * 0.01),
                                                Text(
                                                  "${booking['Quantity'] ?? '1'} Tickets",
                                                  style: TextStyle(
                                                    color: const Color(0xffedb41d),
                                                    fontSize: screenWidth * 0.035,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "\$${booking['Total'] ?? '0'}",
                                              style: TextStyle(
                                                color: const Color(0xffedb41d),
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}