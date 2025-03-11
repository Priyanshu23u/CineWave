import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking/service/constant.dart';
import 'package:movie_booking/service/database.dart';
import 'package:movie_booking/service/shared_pref.dart';
import 'package:random_string/random_string.dart';

class Detailpage extends StatefulWidget {
  final String image, name, shortdetail, moviedetail, price;
  
  const Detailpage({
    Key? key,
    required this.image,
    required this.name,
    required this.shortdetail,
    required this.moviedetail,
    required this.price
  }) : super(key: key);

  @override
  State<Detailpage> createState() => _DetailpageState();
}

class _DetailpageState extends State<Detailpage> {
  
  Map<String, dynamic>? paymentIntent;
  String currentdate = "";
  int track = 0, quantity = 1, total = 0;
  bool twelve = true, three = false, six = false;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    total = int.parse(widget.price);
    getthesharedpref();
    currentdate = getFormattedDates()[0]; // Set initial date
  }
  
  String? id, name;
  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserDisplayName();
    setState(() {});
  }
  
  List<String> getFormattedDates() {
    final now = DateTime.now();
    final formatter = DateFormat('EEE d');
    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return formatter.format(date);
    });
  }
  
  // Get selected time slot
  String getSelectedTimeSlot() {
    if (twelve) return "12:00 PM";
    if (three) return "03:00 PM";
    if (six) return "06:00 PM";
    return "";
  }
  
  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    final dates = getFormattedDates();
    final screenSize = MediaQuery.of(context).size;
    // Adaptive heights based on screen size
    final headerHeight = screenSize.height * 0.4;
    final isSmallScreen = screenSize.width < 360;
    final textScaleFactor = isSmallScreen ? 0.85 : 1.0;
    
    return Scaffold(
      backgroundColor: themeMode == Brightness.dark ? Colors.black : Colors.white,
      // Add AppBar with a back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 16),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Background image
          Image.asset(
            widget.image,
            height: headerHeight,
            width: screenSize.width,
            fit: BoxFit.cover,
          ),
          
          // Content area
          SingleChildScrollView(
            child: Container(
              width: screenSize.width,
              margin: EdgeInsets.only(
                top: headerHeight - 20,
                left: screenSize.width * 0.01,
                right: screenSize.width * 0.01,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.025,
              ),
              decoration: const BoxDecoration(
                color: Color(0xff1e232c),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.07 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Genre
                  Text(
                    widget.shortdetail,
                    style: TextStyle(
                      color: const Color.fromARGB(174, 255, 255, 255),
                      fontSize: screenSize.width * 0.045 * textScaleFactor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.025),
                  // Description
                  Text(
                    widget.moviedetail,
                    style: TextStyle(
                      color: const Color.fromARGB(174, 255, 255, 255),
                      fontSize: screenSize.width * 0.04 * textScaleFactor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Date Selection Title
                  Text(
                    "Select Date",
                    style: TextStyle(
                      color: const Color.fromARGB(174, 255, 255, 255),
                      fontSize: screenSize.width * 0.045 * textScaleFactor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  // Date Selector
                  SizedBox(
                    height: screenSize.height * 0.08,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              track = index;
                              currentdate = dates[index];
                            });
                          },
                          child: Container(
                            width: screenSize.width * 0.28,
                            margin: EdgeInsets.only(right: screenSize.width * 0.04),
                            decoration: BoxDecoration(
                              color: const Color(0xffeed51e),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: track == index ? Colors.white : Colors.black,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                dates[index],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenSize.width * 0.045 * textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Time Slot Selection Title
                  Text(
                    "Select Time Slot",
                    style: TextStyle(
                      color: const Color.fromARGB(174, 255, 255, 255),
                      fontSize: screenSize.width * 0.045 * textScaleFactor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  // Time Slots - Make this row adaptive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Decide whether to use row or wrap based on width
                      if (constraints.maxWidth > 300) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 12:00 PM Slot
                            _buildTimeSlot(
                              context, 
                              "12:00 PM", 
                              twelve, 
                              () {
                                setState(() {
                                  twelve = true;
                                  three = false;
                                  six = false;
                                });
                              }
                            ),
                            // 3:00 PM Slot
                            _buildTimeSlot(
                              context, 
                              "03:00 PM", 
                              three, 
                              () {
                                setState(() {
                                  twelve = false;
                                  three = true;
                                  six = false;
                                });
                              }
                            ),
                            // 6:00 PM Slot
                            _buildTimeSlot(
                              context, 
                              "06:00 PM", 
                              six, 
                              () {
                                setState(() {
                                  twelve = false;
                                  three = false;
                                  six = true;
                                });
                              }
                            ),
                          ],
                        );
                      } else {
                        // For smaller screens, use wrap to allow wrapping
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildTimeSlot(
                              context, 
                              "12:00 PM", 
                              twelve, 
                              () {
                                setState(() {
                                  twelve = true;
                                  three = false;
                                  six = false;
                                });
                              }
                            ),
                            _buildTimeSlot(
                              context, 
                              "03:00 PM", 
                              three, 
                              () {
                                setState(() {
                                  twelve = false;
                                  three = true;
                                  six = false;
                                });
                              }
                            ),
                            _buildTimeSlot(
                              context, 
                              "06:00 PM", 
                              six, 
                              () {
                                setState(() {
                                  twelve = false;
                                  three = false;
                                  six = true;
                                });
                              }
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  
                  // Bottom Bar with Counter and Book Now - ALWAYS IN ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCounterWidget(screenSize, textScaleFactor),
                      _buildBookNowButton(screenSize, textScaleFactor),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Loading Indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffeed51e)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Counter Widget - Updated with responsive width
  Widget _buildCounterWidget(Size screenSize, double textScaleFactor) {
    return Container(
      width: screenSize.width * 0.38, // Adjusted width to fit in row
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                quantity = quantity + 1;
                total = quantity * int.parse(widget.price);
              });
            },
            child: const Icon(Icons.add, color: Colors.white)
          ),
          Text(
            quantity.toString(),
            style: TextStyle(
              color: const Color(0xffeed51e),
              fontSize: screenSize.width * 0.06 * textScaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (quantity > 1) {
                setState(() {
                  quantity = quantity - 1;
                  total = quantity * int.parse(widget.price);
                });
              }
            },
            child: const Icon(Icons.remove, color: Colors.white)
          ),
        ],
      ),
    );
  }

  // Book Now Button - Updated with responsive width
  Widget _buildBookNowButton(Size screenSize, double textScaleFactor) {
    return GestureDetector(
      onTap: () {
        if (currentdate.isNotEmpty && (twelve || three || six)) {
          makePayment(total.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select date and time slot"),
              backgroundColor: Colors.red,
            )
          );
        }
      },
      child: Container(
        width: screenSize.width * 0.5, // Adjusted width to fit in row
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xffeed51e),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Total: \$${total.toString()}",
              style: TextStyle(
                color: Colors.black,
                fontSize: screenSize.width * 0.04 * textScaleFactor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Book Now",
              style: TextStyle(
                color: Colors.black,
                fontSize: screenSize.width * 0.055 * textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build time slot buttons
  Widget _buildTimeSlot(BuildContext context, String time, bool isSelected, VoidCallback onTap) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final textScaleFactor = isSmallScreen ? 0.85 : 1.0;
    
    return GestureDetector(
      onTap: onTap,
      child: isSelected
          ? Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.02,
                  vertical: screenSize.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xffeed51e),
                    width: 5.0,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenSize.width * 0.04 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.02,
                vertical: screenSize.height * 0.008,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xffeed51e),
                  width: 3.0,
                ),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenSize.width * 0.04 * textScaleFactor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      // Show loading indicator
      setState(() {
        isLoading = true;
      });

      // Create payment intent with the correct amount format
      paymentIntent = await createPaymentIntent(amount, 'USD');
      
      // Close loading dialog
      setState(() {
        isLoading = false;
      });
      
      if (paymentIntent == null || !paymentIntent!.containsKey('client_secret')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to create payment. Please check your connection."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Abhinav"
        )
      );

      // Present the payment sheet
      await displayPaymentSheet(amount);
    } catch (e, s) {
      print('Exception in makePayment: $e');
      print('Stack trace: $s');
      
      // Make sure to close loading dialog if still showing
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment initialization failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // Get selected time
      String selectedTime = getSelectedTimeSlot();
      
      // Create booking details with unique ID
      String uniqueId = randomAlphaNumeric(5);
      Map<String, dynamic> userMovieMap = {
        "Movie": widget.name,
        "MovieImage": widget.image,
        "Date": currentdate,
        "Time": selectedTime,
        "Quantity": quantity.toString(),
        "Total": total.toString(),
        "QrId": uniqueId,
        "Name": name,
        "BookingDate": DateTime.now().toString(),
      };
      
      // Check if id is not null before adding booking
      if (id != null) {
        // Add booking to database
        await DatabaseMethods().addUserBooking(userMovieMap, id!);
        await DatabaseMethods().addQrId(uniqueId);
        
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Ticket has been booked Successfully!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
        
        // Show enhanced payment confirmation
        _showEnhancedPaymentConfirmation(userMovieMap, uniqueId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User ID not found. Please try again."),
            backgroundColor: Colors.red,
          )
        );
      }
      
      // Clear payment intent
      paymentIntent = null;
    } on StripeException catch (e) {
      print("Stripe Error: $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Payment Cancelled"),
          content: const Text("Your payment was cancelled."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        )
      );
    } catch (e) {
      print('Error in displayPaymentSheet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment processing error: ${e.toString()}"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Enhanced Payment Confirmation Dialog
  void _showEnhancedPaymentConfirmation(Map<String, dynamic> bookingDetails, String uniqueId) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.9,
              maxHeight: screenSize.height * 0.8,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff1e232c),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xff4CAF50),
                      child: Icon(
                        Icons.check,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Success Title
                    const Text(
                      "Payment Successful!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    
                    // Subtitle
                    const Text(
                      "Your ticket has been booked",
                      style: TextStyle(
                        color: Color(0xffeed51e),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // QR Code Representation (replace with actual QR code if available)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          uniqueId,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Booking Details with custom styling
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Movie", bookingDetails["Movie"], screenSize),
                          const Divider(color: Colors.grey),
                          _buildDetailRow("Date", bookingDetails["Date"], screenSize),
                          const Divider(color: Colors.grey),
                          _buildDetailRow("Time", bookingDetails["Time"], screenSize),
                          const Divider(color: Colors.grey),
                          _buildDetailRow("Tickets", bookingDetails["Quantity"], screenSize),
                          const Divider(color: Colors.grey),
                          _buildDetailRow("Total", "\$${bookingDetails["Total"]}", screenSize),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Note 
                    const Text(
                      "Show this booking confirmation at the counter",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    
                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffeed51e),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper for detail rows in confirmation dialog
  Widget _buildDetailRow(String label, String value, Size screenSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      // Calculate the amount in cents/smallest currency unit
      final calculatedAmount = (int.parse(amount) * 100).toString();
      
      // Create the body parameters
      Map<String, dynamic> body = {
        'amount': calculatedAmount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      
      print("Sending payment intent with amount: $calculatedAmount $currency");
      
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretkey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print("Stripe API response code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("Payment intent created successfully");
        return jsonResponse;
      } else {
        print("Failed to create payment intent: ${response.body}");
        return null;
      }
    } catch (err) {
      print('Error creating payment intent: ${err.toString()}');
      return null;
    }
  }
}