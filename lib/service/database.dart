import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future<QuerySnapshot> getUserbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("Email", isEqualTo: email)
        .get();
  }

  Future addUserBooking(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Booking")
        .add(userInfoMap);
  }

  Future addQrId(String qrid) async {
    return await FirebaseFirestore.instance
        .collection("AllQrCode")
        .doc("q0ylQxcBTfMsLuX9tiaV")
        .update({'QRCode': FieldValue.arrayUnion([qrid])});
  }

  // New method for QR code verification
  Future<bool> verifyQRCode(String qrData) async {
    try {
      print("Verifying QR code: $qrData");
      
      // Get the document with all QR codes
      DocumentSnapshot qrSnapshot = await FirebaseFirestore.instance
          .collection("AllQrCode")
          .doc("q0ylQxcBTfMsLuX9tiaV")
          .get();
      
      if (qrSnapshot.exists) {
        // Get the array of QR codes
        List<dynamic> qrCodes = qrSnapshot.get('QRCode');
        print("Found QR codes in database: ${qrCodes.length}");
        
        // Check if the scanned QR code is in the array
        bool result = qrCodes.contains(qrData);
        print("QR code verification result: $result");
        return result;
      }
      print("QR codes document doesn't exist");
      return false;
    } catch (e) {
      print("Error verifying QR code: $e");
      return false;
    }
  }

  Future<Stream<QuerySnapshot>> getbookings(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Booking")
        .snapshots();
  }

  // New methods for user profile management
  Future updateUserDetails(String userId, Map<String, dynamic> updatedInfo) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(updatedInfo);
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
  }

  // Methods for payment management
  Future addPaymentMethod(String userId, Map<String, dynamic> paymentInfo) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("PaymentMethods")
        .add(paymentInfo);
  }

  Future<QuerySnapshot> getPaymentMethods(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("PaymentMethods")
        .get();
  }

  Future deletePaymentMethod(String userId, String paymentId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("PaymentMethods")
        .doc(paymentId)
        .delete();
  }

  // Methods for notification management
  Future updateNotificationSettings(
      String userId, Map<String, dynamic> notificationSettings) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Settings")
        .doc("notifications")
        .set(notificationSettings, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getNotificationSettings(String userId) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Settings")
        .doc("notifications")
        .get();
  }

  // Methods for booking history
  Future<QuerySnapshot> getPastBookings(String userId) async {
    DateTime now = DateTime.now();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Booking")
        .where("Date", isLessThan: now.toString().substring(0, 10)) // Assuming Date is stored as YYYY-MM-DD
        .get();
  }

  Future<QuerySnapshot> getUpcomingBookings(String userId) async {
    DateTime now = DateTime.now();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Booking")
        .where("Date", isGreaterThanOrEqualTo: now.toString().substring(0, 10))
        .get();
  }

  // Help & Support methods
  Future addSupportTicket(String userId, Map<String, dynamic> ticketInfo) async {
    return await FirebaseFirestore.instance
        .collection("supportTickets")
        .add({
          ...ticketInfo,
          "userId": userId,
          "status": "open",
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  Future<QuerySnapshot> getUserSupportTickets(String userId) async {
    return await FirebaseFirestore.instance
        .collection("supportTickets")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();
  }
}