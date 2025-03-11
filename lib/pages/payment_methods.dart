import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodsPage extends StatefulWidget {
  final String userId;

  const PaymentMethodsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<Map<String, dynamic>> paymentMethods = [];
  bool isLoading = true;
  
  // Controllers for adding new payment method
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedCardType = 'Visa';
  
  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();
  }
  
  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> fetchPaymentMethods() async {
    if (widget.userId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('PaymentMethods')
          .get();

      List<Map<String, dynamic>> methods = [];
      for (var doc in snapshot.docs) {
        methods.add({
          'id': doc.id,
          ...doc.data(),
        });
      }

      setState(() {
        paymentMethods = methods;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching payment methods: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("User ID not found. Please login again."),
        ),
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Format card number to only show last 4 digits for security
      String maskedCardNumber = _cardNumberController.text.replaceAll(' ', '');
      String lastFourDigits = maskedCardNumber.substring(maskedCardNumber.length - 4);
      String displayNumber = "•••• •••• •••• " + lastFourDigits;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('PaymentMethods')
          .add({
            'cardType': _selectedCardType,
            'cardNumber': displayNumber,
            'cardHolder': _cardHolderController.text,
            'expiryDate': _expiryDateController.text,
            'isDefault': paymentMethods.isEmpty, // Make default if it's the first card
            'createdAt': FieldValue.serverTimestamp()
          });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Payment method added successfully!"),
        ),
      );
      
      // Clear form
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryDateController.clear();
      
      // Fetch updated payment methods
      fetchPaymentMethods();
    } catch (e) {
      print("Error adding payment method: $e");
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Failed to add payment method: $e"),
        ),
      );
    }
  }
  
  Future<void> deletePaymentMethod(String id) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('PaymentMethods')
          .doc(id)
          .delete();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Payment method deleted successfully!"),
        ),
      );
      
      fetchPaymentMethods();
    } catch (e) {
      print("Error deleting payment method: $e");
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Failed to delete payment method: $e"),
        ),
      );
    }
  }
  
  Future<void> setDefaultPaymentMethod(String id) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // First, set all payment methods to non-default
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (var method in paymentMethods) {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('PaymentMethods')
            .doc(method['id']);
        
        batch.update(docRef, {'isDefault': false});
      }
      
      // Then set the selected one as default
      DocumentReference defaultRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('PaymentMethods')
          .doc(id);
      
      batch.update(defaultRef, {'isDefault': true});
      
      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Default payment method updated!"),
        ),
      );
      
      fetchPaymentMethods();
    } catch (e) {
      print("Error setting default payment method: $e");
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Failed to set default payment method: $e"),
        ),
      );
    }
  }
  
  void _showAddPaymentMethodModal() {
    final themeMode = Theme.of(context).brightness;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: themeMode == Brightness.dark ? const Color(0xff1D1D2C) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add Payment Method",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Card Type Selector
                      DropdownButtonFormField<String>(
                        value: _selectedCardType,
                        decoration: InputDecoration(
                          labelText: 'Card Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: themeMode == Brightness.dark 
                              ? Colors.black12 
                              : Colors.grey[100],
                        ),
                        items: ['Visa', 'MasterCard', 'American Express', 'Discover']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setModalState(() {
                            _selectedCardType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      // Card Number
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: 'XXXX XXXX XXXX XXXX',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: themeMode == Brightness.dark 
                              ? Colors.black12 
                              : Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      // Card Holder
                      TextFormField(
                        controller: _cardHolderController,
                        decoration: InputDecoration(
                          labelText: 'Card Holder Name',
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: themeMode == Brightness.dark 
                              ? Colors.black12 
                              : Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card holder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      // Expiry Date
                      TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: themeMode == Brightness.dark 
                              ? Colors.black12 
                              : Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            addPaymentMethod();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffedb41d),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Save Card",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    final screenWidth = MediaQuery.of(context).size.width;
    
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
          "Payment Methods",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xffedb41d),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: paymentMethods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                size: 80,
                                color: themeMode == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "No Payment Methods Added",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeMode == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Add a payment method to quickly book tickets",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeMode == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = paymentMethods[index];
                            bool isDefault = method['isDefault'] ?? false;
                            IconData cardIcon;
                            
                            // Set card icon based on card type
                            switch(method['cardType']) {
                              case 'MasterCard':
                                cardIcon = Icons.credit_card;
                                break;
                              case 'American Express':
                                cardIcon = Icons.credit_score;
                                break;
                              case 'Discover':
                                cardIcon = Icons.credit_score_outlined;
                                break;
                              case 'Visa':
                              default:
                                cardIcon = Icons.credit_card;
                                break;
                            }
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isDefault
                                    ? const Color(0xffedb41d).withOpacity(0.1)
                                    : themeMode == Brightness.dark
                                        ? const Color(0xff1D1D2C)
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isDefault
                                      ? const Color(0xffedb41d)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Icon(
                                  cardIcon,
                                  color: const Color(0xffedb41d),
                                  size: 40,
                                ),
                                title: Text(
                                  method['cardNumber'] ?? "•••• •••• •••• ••••",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeMode == Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method['cardHolder'] ?? "Card Holder",
                                      style: TextStyle(
                                        color: themeMode == Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      "Expires: ${method['expiryDate'] ?? 'MM/YY'}",
                                      style: TextStyle(
                                        color: themeMode == Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    if (isDefault)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffedb41d),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Default",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isDefault)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xffedb41d),
                                        ),
                                        onPressed: () => setDefaultPaymentMethod(method['id']),
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[400],
                                      ),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete Payment Method"),
                                          content: const Text(
                                            "Are you sure you want to delete this payment method?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                deletePaymentMethod(method['id']);
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Add Payment Method Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _showAddPaymentMethodModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffedb41d),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Add Payment Method",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}