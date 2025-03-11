import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;
  bool movieUpdatesEnabled = true;
  bool promotionsEnabled = true;
  bool bookingRemindersEnabled = true;
  bool emailNotificationsEnabled = true;
  bool pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadNotificationPreferences();
  }

  Future<void> loadNotificationPreferences() async {
    if (widget.userId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('preferences')
          .doc('notifications')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          movieUpdatesEnabled = data['movieUpdates'] ?? true;
          promotionsEnabled = data['promotions'] ?? true;
          bookingRemindersEnabled = data['bookingReminders'] ?? true;
          emailNotificationsEnabled = data['emailNotifications'] ?? true;
          pushNotificationsEnabled = data['pushNotifications'] ?? true;
        });
      }
    } catch (e) {
      print("Error loading notification preferences: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveNotificationPreferences() async {
    if (widget.userId.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('preferences')
          .doc('notifications')
          .set({
        'movieUpdates': movieUpdatesEnabled,
        'promotions': promotionsEnabled,
        'bookingReminders': bookingRemindersEnabled,
        'emailNotifications': emailNotificationsEnabled,
        'pushNotifications': pushNotificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Notification preferences saved!",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      print("Error saving notification preferences: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Failed to save preferences. Please try again!",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
          "Notifications",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xffedb41d),
              ),
            )
          : SingleChildScrollView(
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
                          "Notification Settings",
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
                          "Customize how you want to receive notifications about movies, bookings, and promotions.",
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

                  // Notification Types
                  Text(
                    "Notification Types",
                    style: TextStyle(
                      color:
                          themeMode == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Movie Updates
                  NotificationSwitchTile(
                    icon: Icons.movie_outlined,
                    title: "Movie Updates",
                    subtitle: "Get notified about new releases and movie news",
                    value: movieUpdatesEnabled,
                    onChanged: (value) {
                      setState(() {
                        movieUpdatesEnabled = value;
                      });
                    },
                    themeMode: themeMode,
                  ),

                  // Promotions
                  NotificationSwitchTile(
                    icon: Icons.local_offer_outlined,
                    title: "Promotions & Offers",
                    subtitle: "Receive special offers and discounts",
                    value: promotionsEnabled,
                    onChanged: (value) {
                      setState(() {
                        promotionsEnabled = value;
                      });
                    },
                    themeMode: themeMode,
                  ),

                  // Booking Reminders
                  NotificationSwitchTile(
                    icon: Icons.calendar_today_outlined,
                    title: "Booking Reminders",
                    subtitle: "Reminders about your upcoming movie bookings",
                    value: bookingRemindersEnabled,
                    onChanged: (value) {
                      setState(() {
                        bookingRemindersEnabled = value;
                      });
                    },
                    themeMode: themeMode,
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Notification Channels
                  Text(
                    "Notification Channels",
                    style: TextStyle(
                      color:
                          themeMode == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Email Notifications
                  NotificationSwitchTile(
                    icon: Icons.email_outlined,
                    title: "Email Notifications",
                    subtitle: "Receive notifications via email",
                    value: emailNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        emailNotificationsEnabled = value;
                      });
                    },
                    themeMode: themeMode,
                  ),

                  // Push Notifications
                  NotificationSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: "Push Notifications",
                    subtitle: "Receive notifications on your device",
                    value: pushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        pushNotificationsEnabled = value;
                      });
                    },
                    themeMode: themeMode,
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Save Button
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : saveNotificationPreferences,
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
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Save Preferences",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
    );
  }
}

class NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final Brightness themeMode;

  const NotificationSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: const Color(0xffedb41d).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xffedb41d),
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeMode == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeMode == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xffedb41d),
            activeTrackColor: const Color(0xffedb41d).withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}