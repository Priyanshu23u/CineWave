import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/pages/bottomnav.dart';
import 'package:movie_booking/pages/home.dart';
import 'package:movie_booking/pages/signup.dart';
import 'package:movie_booking/service/database.dart';
import 'package:movie_booking/service/shared_pref.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "", myname = "", myid = "", myimage = "";
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> userLogin() async {
    setState(() {
      isLoading = true;
    });

    email = mailController.text.trim();
    password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        QuerySnapshot querySnapshot =
            await DatabaseMethods().getUserbyemail(email);

        if (querySnapshot.docs.isNotEmpty) {
          myname = querySnapshot.docs[0]["Name"];
          myid = querySnapshot.docs[0]["Id"];
          myimage = querySnapshot.docs[0]["Image"];

          await SharedPreferenceHelper().saveUserImage(myimage);
          await SharedPreferenceHelper().saveUserId(myid);
          await SharedPreferenceHelper().saveUserEmail(email);
          await SharedPreferenceHelper().saveUserDisplayName(myname);

          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Login Successful!",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Bottomnav()));
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        String errorMessage = "An error occurred. Please try again.";

        if (e.code == 'user-not-found') {
          errorMessage = "No user found for this email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Wrong password entered.";
        } else if (e.code.contains('invalid-credential')) {
          errorMessage = "Invalid Credential";
        } else if (e.code == 'too-many-requests') {
          errorMessage = "Too many failed attempts. Please try again later.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(errorMessage,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("Please enter email and password!",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff14141d),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "images/signin1.png",
              width: screenWidth,
              height: screenHeight * 0.35, // Responsive height
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome!",
                    style: TextStyle(
                      color: Color.fromARGB(157, 255, 255, 255),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06), // Responsive spacing

                  // Email Input
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                    ),
                  ),
                  TextField(
                    controller: mailController,
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                      hintStyle: TextStyle(color: Colors.white54),
                      suffixIcon: Icon(Icons.email, color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Password Input
                  const Text(
                    "Password",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                    ),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sign Up Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Signup()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          width: screenWidth * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Login Button
                      GestureDetector(
                        onTap: userLogin,
                        child: Container(
                          width: screenWidth * 0.4,
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
