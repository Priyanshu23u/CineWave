import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  bool isSubmitting = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _sendSupportRequest() async {
    // Validate inputs
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Please fill in all fields",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Simulating sending to backend
    try {
      // In a real app, you would send this data to your backend or a service like Firebase
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Clear the form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Your request has been submitted! We'll get back to you soon.",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Failed to submit request. Please try again later.",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
  
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Could not launch $url",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          themeMode == Brightness.dark ? Colors.black : Colors.white,
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
          "Help & Support",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: themeMode == Brightness.dark
                    ? const Color(0xff1D1D2C)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "How can we help you?",
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "We're here to assist you with any questions or issues you might have with your bookings or our service.",
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // FAQ Section
            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // FAQ Items
            FAQItem(
              question: "How do I cancel my booking?",
              answer: "You can cancel your booking by going to your Booking History and selecting the booking you wish to cancel. Please note that cancellations made less than 24 hours before showtime may not be eligible for a full refund.",
              themeMode: themeMode,
            ),

            FAQItem(
              question: "Can I change my seat selection?",
              answer: "Yes, you can change your seat selection up to 2 hours before showtime, subject to availability. Go to your Booking History, select the booking, and tap on 'Change Seats'.",
              themeMode: themeMode,
            ),

            FAQItem(
              question: "How do I redeem a promo code?",
              answer: "You can enter your promo code on the payment screen during checkout. The discount will be applied automatically if the code is valid.",
              themeMode: themeMode,
            ),

            FAQItem(
              question: "What is your refund policy?",
              answer: "Refunds are processed within 5-7 business days to your original payment method. Cancellations made more than 24 hours before showtime are eligible for a full refund. Late cancellations may be subject to partial refunds or theater credits.",
              themeMode: themeMode,
            ),

            SizedBox(height: screenHeight * 0.03),

            // Contact Options
            Text(
              "Contact Us",
              style: TextStyle(
                color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Contact Options Grid
            Row(
              children: [
                Expanded(
                  child: ContactOptionCard(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    onTap: () => _launchURL("mailto:support@moviebooking.com"),
                    themeMode: themeMode,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: ContactOptionCard(
                    icon: Icons.phone_outlined,
                    title: "Call Support",
                    onTap: () => _launchURL("tel:+18001234567"),
                    themeMode: themeMode,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),
            Row(
              children: [
                Expanded(
                  child: ContactOptionCard(
                    icon: Icons.chat_outlined,
                    title: "Live Chat",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.blue,
                          content: Text(
                            "Live chat is available from 9 AM to 8 PM",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    },
                    themeMode: themeMode,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: ContactOptionCard(
                    icon: Icons.help_center_outlined,
                    title: "Help Center",
                    onTap: () => _launchURL("https://help.moviebooking.com"),
                    themeMode: themeMode,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // Support Form
            Text(
              "Send Us a Message",
              style: TextStyle(
                color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: themeMode == Brightness.dark
                    ? const Color(0xff1D1D2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: themeMode == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Name Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Your Name",
                      labelStyle: TextStyle(
                        color: themeMode == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xffedb41d)),
                      ),
                    ),
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: TextStyle(
                        color: themeMode == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xffedb41d)),
                      ),
                    ),
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Message Field
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "How can we help you?",
                      labelStyle: TextStyle(
                        color: themeMode == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xffedb41d)),
                      ),
                    ),
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Submit Button
                  GestureDetector(
                    onTap: isSubmitting ? null : _sendSupportRequest,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xffedb41d),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Submit Request",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final Brightness themeMode;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    required this.themeMode,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.themeMode == Brightness.dark
            ? const Color(0xff1D1D2C)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeMode == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        title: Text(
          widget.question,
          style: TextStyle(
            color: widget.themeMode == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.remove : Icons.add,
          color: const Color(0xffedb41d),
        ),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom: screenWidth * 0.04,
            ),
            child: Text(
              widget.answer,
              style: TextStyle(
                color: widget.themeMode == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function() onTap;
  final Brightness themeMode;

  const ContactOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.12,
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: themeMode == Brightness.dark
              ? const Color(0xff1D1D2C)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeMode == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xffedb41d),
              size: screenWidth * 0.08,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeMode == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}