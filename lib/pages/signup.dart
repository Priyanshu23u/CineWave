import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/pages/bottomnav.dart';
import 'package:movie_booking/pages/login.dart';
import 'package:movie_booking/service/database.dart';
import 'package:movie_booking/service/shared_pref.dart';
import 'package:random_string/random_string.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool isLoading = false;

  Future<void> registration() async {
    setState(() => isLoading = true);

    String name = nameController.text.trim();
    String email = mailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String id = randomAlphaNumeric(10);
        String defaultImage = "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/ico1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a";

        Map<String, dynamic> userInfoMap = {
          "Name": name,
          "Email": email,
          "Id": id,
          "Image": defaultImage,
        };

        await SharedPreferenceHelper().saveUserDisplayName(name);
        await SharedPreferenceHelper().saveUserEmail(email);
        await SharedPreferenceHelper().saveUserId(id);
        await SharedPreferenceHelper().saveUserImage(defaultImage);
        await DatabaseMethods().addUserDetails(userInfoMap, id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registered Successfully!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bottomnav()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred";

        if (e.code == 'weak-password') {
          errorMessage = "Password is too weak.";
        } else if (e.code == "email-already-in-use") {
          errorMessage = "Account already exists.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(errorMessage, style: const TextStyle(fontSize: 18)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("All fields are required!", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff14141d),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image filling upper corners
              Container(
                width: double.infinity,
                height: screenHeight * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/signin1.png"),
                    fit: BoxFit.cover, // Makes the image fill the upper part completely
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // Name Field
                    buildInputLabel("Name"),
                    buildTextField(nameController, "Enter Name", Icons.person, false),

                    // Email Field
                    buildInputLabel("Email"),
                    buildTextField(mailController, "Enter Email", Icons.email, false),

                    // Password Field
                    buildInputLabel("Password"),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(color: Colors.white54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() => _isPasswordVisible = !_isPasswordVisible);
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    Center(
                      child: GestureDetector(
                        onTap: registration,
                        child: Container(
                          width: screenWidth * 0.6,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.white70, fontSize: 18)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                          },
                          child: const Text(" Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 20)),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText, IconData icon, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: Icon(icon, color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
    );
  }
}
