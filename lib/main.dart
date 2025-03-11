import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:movie_booking/pages/booking.dart';
import 'package:movie_booking/pages/bottomnav.dart';
import 'package:movie_booking/pages/detailpage.dart';
import 'package:movie_booking/pages/home.dart';
import 'package:movie_booking/pages/login.dart';
import 'package:movie_booking/pages/signup.dart';
import 'package:movie_booking/pages/themeprovider.dart';
import 'package:movie_booking/pages/verifyqr.dart';
import 'package:movie_booking/service/constant.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishedkey;
  await Firebase.initializeApp();
  FirebaseAppCheck.instance.activate();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getTheme(),
          home: Login(),
        );
      },
    );
  }
}

