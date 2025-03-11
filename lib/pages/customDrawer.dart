import 'package:flutter/material.dart';
import 'package:movie_booking/pages/profile.dart';
import 'package:movie_booking/pages/themeprovider.dart';
import 'package:movie_booking/service/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_booking/pages/login.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String username = "User";
  String userEmail = "";
  String userImage = "images/boy.jpg";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String? name = await SharedPreferenceHelper().getUserDisplayName();
    String? email = await SharedPreferenceHelper().getUserEmail();
    String? image = await SharedPreferenceHelper().getUserImage();

    setState(() {
      if (name != null && name.isNotEmpty) username = name;
      if (email != null && email.isNotEmpty) userEmail = email;
      if (image != null && image.isNotEmpty) userImage = image;
    });
  }

  Future<void> logoutUser() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signOut();
      await SharedPreferenceHelper().clearUserData();
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Logged out successfully!",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    } catch (e) {
      setState(() => isLoading = false);
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

  // Navigation functions for drawer items
  void navigateToPersonalInfo() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonalInformationPage()),
    );
  }

  void navigateToPaymentMethods() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentMethodsPage()),
    );
  }

  void navigateToBookingHistory() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingHistoryPage()),
    );
  }

  void navigateToNotifications() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsPage()),
    );
  }

  void navigateToHelpSupport() {
    Navigator.pop(context);
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => HelpSupportPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: screenWidth * 0.75,
      backgroundColor: isDarkMode ? Color(0xff121212) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with user info
          Container(
            padding: EdgeInsets.only(
              top: screenHeight * 0.06,
              bottom: screenHeight * 0.02,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            color: isDarkMode ? Color(0xff1D1D2C) : Color(0xffedb41d).withOpacity(0.2),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xffedb41d), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.1),
                    child: userImage.startsWith("http")
                        ? Image.network(
                            userImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset("images/boy.jpg", fit: BoxFit.cover),
                          )
                        : Image.asset(userImage, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  username,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle
          ListTile(
            title: Text(
              "Theme",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: screenWidth * 0.045),
            ),
            subtitle: Text(
              isDarkMode ? "Dark Mode" : "Light Mode",
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: screenWidth * 0.035),
            ),
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: const Color(0xffedb41d),
              size: screenWidth * 0.06,
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
              activeColor: const Color(0xffedb41d),
            ),
          ),

          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),

          // Drawer Items with Navigation
          _buildDrawerItem(
            context, 
            icon: Icons.person, 
            title: "Personal Information", 
            isDarkMode: isDarkMode,
            onTap: navigateToPersonalInfo,
          ),
          _buildDrawerItem(
            context, 
            icon: Icons.credit_card, 
            title: "Payment Methods", 
            isDarkMode: isDarkMode,
            onTap: navigateToPaymentMethods,
          ),
          _buildDrawerItem(
            context, 
            icon: Icons.history, 
            title: "Booking History", 
            isDarkMode: isDarkMode,
            onTap: navigateToBookingHistory,
          ),
          _buildDrawerItem(
            context, 
            icon: Icons.notifications, 
            title: "Notifications", 
            isDarkMode: isDarkMode,
            onTap: navigateToNotifications,
          ),
          _buildDrawerItem(
            context, 
            icon: Icons.help, 
            title: "Help & Support", 
            isDarkMode: isDarkMode,
            onTap: navigateToHelpSupport,
          ),

          Divider(color: isDarkMode ? Colors.white24 : Colors.black12),

          // View Profile Button
          ListTile(
            title: Text(
              "View Profile",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
            ),
            leading: Icon(Icons.account_circle, color: const Color(0xffedb41d), size: screenWidth * 0.06),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile())),
          ),

          // Logout Option
          ListTile(
            title: Text(
              "Logout",
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: screenWidth * 0.045, fontWeight: FontWeight.w500),
            ),
            leading: Icon(Icons.logout, color: Colors.redAccent, size: screenWidth * 0.06),
            onTap: isLoading ? null : logoutUser,
            trailing: isLoading
                ? SizedBox(
                    width: screenWidth * 0.05,
                    height: screenWidth * 0.05,
                    child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xffedb41d)),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
      leading: Icon(icon, color: const Color(0xffedb41d)),
      onTap: onTap,
    );
  }
}

// Placeholder pages for navigation
// You'll need to create these pages or replace with your actual pages

class PersonalInformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Information'),
        backgroundColor: const Color(0xffedb41d),
      ),
      body: Center(
        child: Text('Personal Information Page'),
      ),
    );
  }
}

class PaymentMethodsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        backgroundColor: const Color(0xffedb41d),
      ),
      body: Center(
        child: Text('Payment Methods Page'),
      ),
    );
  }
}

class BookingHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking History'),
        backgroundColor: const Color(0xffedb41d),
      ),
      body: Center(
        child: Text('Booking History Page'),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: const Color(0xffedb41d),
      ),
      body: Center(
        child: Text('Notifications Page'),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: const Color(0xffedb41d),
      ),
      body: Center(
        child: Text('Help & Support Page'),
      ),
    );
  }
}