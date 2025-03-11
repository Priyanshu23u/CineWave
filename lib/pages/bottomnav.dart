import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/pages/booking.dart';
import 'package:movie_booking/pages/detailpage.dart';
import 'package:movie_booking/pages/home.dart';
import 'package:movie_booking/pages/profile.dart';


class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});
 
  
  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget>pages;
  late Home HomePage;
  late Booking booking;
  late Profile profile;

  int currentTabIndex = 0;

  @override
  void initState() {
    HomePage = Home();
    booking = Booking();
    profile = Profile();

    pages= [HomePage,booking,profile];
    super.initState();
    
  }
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness;
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: themeMode == Brightness.dark ? Colors.black : Colors.white,
        color: Color.fromARGB(255, 204, 151, 7),
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },

        items: [
          Icon(
            Icons.home,
            color: Colors.white,
            size: 30,

          ),
          Icon(Icons.book,color: Colors.white,size: 30,),
          Icon(Icons.person,color: Colors.white,size: 30,),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}