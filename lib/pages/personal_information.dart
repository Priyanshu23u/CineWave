import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:movie_booking/service/shared_pref.dart';

class PersonalInformation extends StatefulWidget {
  final String userId;
  final String initialName;
  final String initialEmail;
  final String initialImage;

  const PersonalInformation({
    Key? key,
    required this.userId,
    required this.initialName,
    required this.initialEmail,
    required this.initialImage,
  }) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String userImage = "images/boy.jpg";
  bool isLoading = false;
  File? _imageFile;
  String? phoneNumber;
  
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
    phoneController = TextEditingController();
    userImage = widget.initialImage;
    
    // Load user data
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          phoneNumber = data['phone'];
          if (phoneNumber != null && phoneNumber!.isNotEmpty) {
            phoneController.text = phoneNumber!;
          }
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    String imageUrl = userImage;
    
    try {
      // Upload image if a new one was selected
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }
      
      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'profileImage': imageUrl,
      });
      
      // Update shared preferences
      await SharedPreferenceHelper().saveUserDisplayName(nameController.text.trim());
      await SharedPreferenceHelper().saveUserImage(imageUrl);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: $e"),
          backgroundColor: Colors.red,
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
          "Personal Information",
          style: TextStyle(
            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: const Color(0xffedb41d)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: screenWidth * 0.35,
                        height: screenWidth * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xffedb41d), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(screenWidth * 0.175),
                          child: _imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                )
                              : userImage.startsWith("http")
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: BoxDecoration(
                              color: const Color(0xffedb41d),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: themeMode == Brightness.dark ? Colors.black : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: screenWidth * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: screenHeight * 0.04),
                  
                  // Form Fields
                  Container(
                    decoration: BoxDecoration(
                      color: themeMode == Brightness.dark ? const Color(0xff1D1D2C) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        // Name Field
                        TextField(
                          controller: nameController,
                          style: TextStyle(
                            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(
                              color: themeMode == Brightness.dark ? Colors.white70 : Colors.black54,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: const Color(0xffedb41d),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: themeMode == Brightness.dark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xffedb41d),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Email Field (Read Only)
                        TextField(
                          controller: emailController,
                          readOnly: true,
                          style: TextStyle(
                            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            labelStyle: TextStyle(
                              color: themeMode == Brightness.dark ? Colors.white70 : Colors.black54,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: const Color(0xffedb41d),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: themeMode == Brightness.dark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xffedb41d),
                              ),
                            ),
                            filled: true,
                            fillColor: themeMode == Brightness.dark 
                                ? Colors.white.withOpacity(0.05) 
                                : Colors.grey.withOpacity(0.05),
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Phone Field
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(
                              color: themeMode == Brightness.dark ? Colors.white70 : Colors.black54,
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: const Color(0xffedb41d),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: themeMode == Brightness.dark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: const Color(0xffedb41d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.04),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffedb41d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save, color: Colors.black),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}