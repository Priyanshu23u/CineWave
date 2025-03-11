import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking/pages/customDrawer.dart';
import 'package:movie_booking/pages/detailpage.dart';
import 'package:movie_booking/pages/profile.dart';
import 'package:movie_booking/service/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Carousel slider movies with details
  final List<Map<String, dynamic>> carouselMovies = [
    {
      "image": "images/infinity.jpg",
      "name": "Infinity Wars",
      "shortdetail": "Action, Adventure",
      "moviedetail": "The Avengers and their allies must be willing to sacrifice all in an attempt to defeat the powerful Thanos before his blitz of devastation and ruin puts an end to the universe.",
      "price": "50"
    },
    {
      "image": "images/salman.jpg",
      "name": "Tiger 3",
      "shortdetail": "Action, Thriller",
      "moviedetail": "RAW agent Tiger teams up with Zoya to rescue foreign delegates held hostage by a terrorist organization.",
      "price": "40"
    },
    {
      "image": "images/shahrukhmovies.png",
      "name": "Jawan",
      "shortdetail": "Action, Drama",
      "moviedetail": "A prison warden recruits inmates to commit outrageous crimes that shed light on corruption and injustice, all in a bid to save India.",
      "price": "45"
    },
  ];
  
  // Trending movies with details
  final List<Map<String, dynamic>> trendingMovies = [
    {
      "image": "images/infinity.jpg",
      "name": "Infinity Wars",
      "shortdetail": "Action, Adventure",
      "moviedetail": "The Avengers and their allies must be willing to sacrifice all in an attempt to defeat the powerful Thanos before his blitz of devastation and ruin puts an end to the universe.",
      "price": "50"
    },
    {
      "image": "images/pushpa.jpg",
      "name": "Pushpa 2",
      "shortdetail": "Action, Drama",
      "moviedetail": "After escaping a police raid, Pushpa Raj rises through the ranks of a sandalwood smuggling syndicate and faces off against the ruthless police officer Bhanwar Singh Shekhawat.",
      "price": "45"
    },
    {
      "image": "images/salman.jpg",
      "name": "Tiger 3",
      "shortdetail": "Action, Thriller",
      "moviedetail": "RAW agent Tiger teams up with Zoya to rescue foreign delegates held hostage by a terrorist organization.",
      "price": "40"
    },
    {
      "image": "images/shahrukhmovies.png",
      "name": "Jawan",
      "shortdetail": "Action, Drama",
      "moviedetail": "A prison warden recruits inmates to commit outrageous crimes that shed light on corruption and injustice, all in a bid to save India.",
      "price": "45"
    }
  ];
  
  String username = "User";
  String userImage = "images/boy.jpg";

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    String? name = await SharedPreferenceHelper().getUserDisplayName();
    String? image = await SharedPreferenceHelper().getUserImage();
    
    if (name != null && name.isNotEmpty) {
      setState(() {
        username = name;
      });
    }
    
    if (image != null && image.isNotEmpty) {
      setState(() {
        userImage = image;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final themeMode = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: themeMode == Brightness.dark ? Colors.black : Colors.white,
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile
                Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Icon(
                          Icons.menu,
                          color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                          size: screenWidth * 0.07,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Image.asset(
                      "images/wave.png",
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.1,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Hello, $username",
                      style: TextStyle(
                        color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Profile()),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: userImage.startsWith("http")
                            ? Image.network(
                                userImage,
                                height: screenHeight * 0.05,
                                width: screenWidth * 0.1,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "images/boy.jpg",
                                    height: screenHeight * 0.05,
                                    width: screenWidth * 0.1,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                userImage,
                                height: screenHeight * 0.05,
                                width: screenWidth * 0.1,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Welcome To,",
                  style: TextStyle(
                    color: themeMode == Brightness.dark 
                        ? Color.fromARGB(186, 255, 255, 255) 
                        : Color.fromARGB(186, 0, 0, 0),
                    fontSize: screenWidth * 0.042,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Filmy",
                      style: TextStyle(
                        color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Fun",
                      style: TextStyle(
                        color: Color(0xffedb41d),
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // Carousel Section - All images clickable
                CarouselSlider(
                  items: carouselMovies.map((movie) {
                    return Builder(builder: ((context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detailpage(
                                image: movie["image"],
                                name: movie["name"],
                                shortdetail: movie["shortdetail"],
                                moviedetail: movie["moviedetail"],
                                price: movie["price"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth,
                          height: screenHeight * 0.3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  movie["image"],
                                  width: screenWidth,
                                  height: screenHeight * 0.3,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Title overlay
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                    vertical: screenHeight * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    movie["name"],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
                  }).toList(),
                  options: CarouselOptions(
                    height: screenHeight * 0.3,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    autoPlayAnimationDuration: Duration(seconds: 2),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Top Trending Movies",
                  style: TextStyle(
                    color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                
                // Rest of the code remains the same but update text colors for dark/light mode
                // Trending Movies - Horizontal Scroll
                Container(
                  height: screenHeight * 0.32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingMovies.length,
                    itemBuilder: (context, index) {
                      final movie = trendingMovies[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detailpage(
                                image: movie["image"],
                                name: movie["name"],
                                shortdetail: movie["shortdetail"],
                                moviedetail: movie["moviedetail"],
                                price: movie["price"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.42,
                          margin: EdgeInsets.only(right: screenWidth * 0.04),
                          decoration: BoxDecoration(
                            border: Border.all(color: themeMode == Brightness.dark ? Colors.white : Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  movie["image"],
                                  height: screenHeight * 0.28,
                                  width: screenWidth * 0.42,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                    vertical: screenHeight * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie["name"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        movie["shortdetail"],
                                        style: TextStyle(
                                          color: Color.fromARGB(173, 255, 255, 255),
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w500,
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
                
                // New Releases section
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "New Releases",
                  style: TextStyle(
                    color: themeMode == Brightness.dark ? Colors.white : Colors.black,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                
                Container(
                  height: screenHeight * 0.32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trendingMovies.length,
                    itemBuilder: (context, index) {
                      // Use the same data but in different order
                      final movie = trendingMovies[trendingMovies.length - 1 - index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detailpage(
                                image: movie["image"],
                                name: movie["name"],
                                shortdetail: movie["shortdetail"],
                                moviedetail: movie["moviedetail"],
                                price: movie["price"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: screenWidth * 0.42,
                          margin: EdgeInsets.only(right: screenWidth * 0.04),
                          decoration: BoxDecoration(
                            border: Border.all(color: themeMode == Brightness.dark ? Colors.white : Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  movie["image"],
                                  height: screenHeight * 0.28,
                                  width: screenWidth * 0.42,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                    vertical: screenHeight * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie["name"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.045,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        movie["shortdetail"],
                                        style: TextStyle(
                                          color: Color.fromARGB(173, 255, 255, 255),
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.w500,
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
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}