import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/pages/bottomnav.dart';
import 'package:movie_booking/pages/help_support_page.dart';
import 'package:movie_booking/pages/home.dart';
import 'package:movie_booking/pages/login.dart';
import 'package:movie_booking/pages/personal_information.dart';
import 'package:movie_booking/pages/profile_section_widget.dart';
import 'package:movie_booking/service/shared_pref.dart';
import 'package:movie_booking/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_booking/pages/payment_methods.dart';
import 'package:movie_booking/pages/booking_history.dart';
import 'package:movie_booking/pages/notifications_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String username = "User";
  String userEmail = "";
  String userImage = "images/boy.jpg";
  String? userId;
  bool isLoading = false;
  List<Map<String, dynamic>> userBookings = [];
  bool isLoadingBookings = true;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String? name = await SharedPreferenceHelper().getUserDisplayName();
    String? email = await SharedPreferenceHelper().getUserEmail();
    String? image = await SharedPreferenceHelper().getUserImage();
    String? id = await SharedPreferenceHelper().getUserId();

    if (name != null && name.isNotEmpty) {
      setState(() {
        username = name;
      });
    }

    if (email != null && email.isNotEmpty) {
      setState(() {
        userEmail = email;
      });
    }

    if (image != null && image.isNotEmpty) {
      setState(() {
        userImage = image;
      });
    }

    if (id != null && id.isNotEmpty) {
      setState(() {
        userId = id;
      });
      getUserBookings();
    }
  }

  Future<void> getUserBookings() async {
    if (userId == null) return;

    setState(() {
      isLoadingBookings = true;
    });

    try {
      // Print the userId to verify it's correct
      print("Fetching bookings for userId: $userId");

      // Get current date
      DateTime now = DateTime.now();

      // Get future bookings only
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('Booking')
          .where('Date',
              isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day)
                  .toString()
                  .substring(0, 10))
          .orderBy('Date')
          .get();

      // Debug: Print how many documents were found
      print("Found ${snapshot.docs.length} future booking documents");

      List<Map<String, dynamic>> bookingsData = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Add the document ID and all data to our list
        bookingsData.add({
          'id': doc.id,
          ...data,
        });
      }

      setState(() {
        userBookings = bookingsData;
        isLoadingBookings = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoadingBookings = false;
      });
    }
  }

  Future<void> logoutUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      await SharedPreferenceHelper().clearUserData();

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Logged out successfully!",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false, // This removes all previous routes
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Failed to log out. Please try again!",
            style: TextStyle(fontSize: 18, color: Colors.white),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Bottomnav()),
            );
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with background
            Container(
              width: double.infinity,
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/signin1.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Picture
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.125),
                      child: userImage.startsWith("http")
                          ? Image.network(
                              userImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "images/boy.jpg",
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              userImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Username
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Email
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Content
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Bookings Section
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Upcoming Bookings",
                        style: TextStyle(
                          color: themeMode == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: getUserBookings,
                        child: Icon(
                          Icons.refresh,
                          color: const Color(0xffedb41d),
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Bookings List
                  isLoadingBookings
                      ? Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xffedb41d),
                          ),
                        )
                      : userBookings.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.05,
                                horizontal: screenWidth * 0.05,
                              ),
                              decoration: BoxDecoration(
                                color: themeMode == Brightness.dark
                                    ? const Color(0xff1D1D2C)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_movies_outlined,
                                    color: themeMode == Brightness.dark
                                        ? Colors.white70
                                        : Colors.black54,
                                    size: screenWidth * 0.15,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    "No upcoming bookings found",
                                    style: TextStyle(
                                      color: themeMode == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    "Your future movie tickets will appear here",
                                    style: TextStyle(
                                      color: themeMode == Brightness.dark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              height: screenHeight * 0.3,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: userBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = userBookings[index];
                                  return Container(
                                    width: screenWidth * 0.7,
                                    margin: EdgeInsets.only(
                                        right: screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: themeMode == Brightness.dark
                                          ? const Color(0xff1D1D2C)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xff6b63ff)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Movie Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          child: Image.asset(
                                            booking['MovieImage'] ??
                                                "images/infinity.jpg",
                                            height: screenHeight * 0.15,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Booking Details
                                        Padding(
                                          padding: EdgeInsets.all(
                                              screenWidth * 0.03),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                booking['Movie'] ??
                                                    "Unknown Movie",
                                                style: TextStyle(
                                                  color: themeMode ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.005),
                                              Text(
                                                "${booking['Date'] ?? 'Unknown Date'} | ${booking['Time'] ?? 'Unknown Time'}",
                                                style: TextStyle(
                                                  color: themeMode ==
                                                          Brightness.dark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: screenWidth * 0.035,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.005),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${booking['Quantity'] ?? '1'} Tickets",
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xffedb41d),
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$${booking['Total'] ?? '0'}",
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xffedb41d),
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                  // Profile Options
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    "Profile Options",
                    style: TextStyle(
                      color: themeMode == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Profile sections with the new widget
                  ProfileSectionWidget(
                    icon: Icons.person,
                    title: "Personal Information",
                    subtitle: "View and edit your personal details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInformation(
                            userId: userId ?? "",
                            initialName: username,
                            initialEmail: userEmail,
                            initialImage: userImage,
                          ),
                        ),
                      ).then((_) => getUserInfo());
                    },
                  ),

                  ProfileSectionWidget(
                    icon: Icons.credit_card,
                    title: "Payment Methods",
                    subtitle: "Manage your payment options",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentMethodsPage(userId: userId ?? ""),
                        ),
                      );
                    },
                  ),

                  ProfileSectionWidget(
                    icon: Icons.history,
                    title: "Booking History",
                    subtitle: "View your previous movie bookings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingHistoryPage(userId: userId ?? ""),
                        ),
                      );
                    },
                  ),

                  ProfileSectionWidget(
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "Manage your notification preferences",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationsPage(userId: userId ?? ""),
                        ),
                      );
                    },
                  ),

                  ProfileSectionWidget(
                    icon: Icons.help,
                    title: "Help & Support",
                    subtitle: "Get help with your booking and queries",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpSupportPage(),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Logout Button
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : logoutUser,
                      child: Container(
                        width: screenWidth * 0.6,
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: const Color(0xffedb41d),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffedb41d).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.black,
                                      size: screenWidth * 0.06,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
