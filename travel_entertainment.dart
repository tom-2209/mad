import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

/// 🌈 Gradient Background
Widget bg(child) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: child,
  );
}

/// ================= HOME =================
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bg(
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🌍 Travel & Fun",
                  style: TextStyle(fontSize: 28, color: Colors.white)),

              SizedBox(height: 30),

              btn(context, "🎬 Movies", MovieScreen()),
              btn(context, "✈️ Travel", TravelScreen()),
              btn(context, "👉 Swipe", SwipeScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget btn(context, text, screen) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(200, 50),
            backgroundColor: Colors.white),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Text(text, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

/// ================= MOVIE =================
class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List movies = ["Leo", "Jailer", "Vikram"];
  int index = 0;
  double rating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bg(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Select Movie",
                  style: TextStyle(fontSize: 22, color: Colors.white)),

              DropdownButton(
                value: index,
                dropdownColor: Colors.black,
                items: List.generate(movies.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child:
                    Text(movies[i], style: TextStyle(color: Colors.white)),
                  );
                }),
                onChanged: (val) => setState(() => index = val as int),
              ),

              Slider(
                value: rating,
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (val) => setState(() => rating = val),
              ),

              Text("⭐ $rating",
                  style: TextStyle(fontSize: 28, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= TRAVEL =================
class TravelScreen extends StatefulWidget {
  @override
  _TravelScreenState createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  List places = [
    {"name": "Goa", "cost": 8},
    {"name": "Ooty", "cost": 6},
  ];

  int index = 0;
  TextEditingController distance = TextEditingController();
  double total = 0;

  void calc() {
    double d = double.tryParse(distance.text) ?? 0;
    setState(() => total = d * places[index]["cost"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bg(
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton(
                value: index,
                dropdownColor: Colors.black,
                items: List.generate(places.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(places[i]["name"],
                        style: TextStyle(color: Colors.white)),
                  );
                }),
                onChanged: (val) => setState(() => index = val as int),
              ),

              TextField(
                controller: distance,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    filled: true, fillColor: Colors.white),
              ),

              SizedBox(height: 20),

              ElevatedButton(onPressed: calc, child: Text("Calculate")),

              SizedBox(height: 20),

              Text("₹ $total",
                  style: TextStyle(fontSize: 28, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= SWIPE =================
class SwipeScreen extends StatelessWidget {
  final List places = [
    {
      "name": "Goa",
      "desc": "Beach 🌴",
      "cost": "₹5000",
      "color": Colors.orange
    },
    {
      "name": "Paris",
      "desc": "Romantic ❤️",
      "cost": "₹80000",
      "color": Colors.pink
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swipe")),
      body: CardSwiper(
        cardsCount: places.length,
        numberOfCardsDisplayed: 2,
        cardBuilder: (context, index, _, __) {
          var p = places[index];

          return Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p["color"],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p["name"],
                      style: TextStyle(fontSize: 26, color: Colors.white)),
                  Text(p["desc"], style: TextStyle(color: Colors.white)),
                  Text(p["cost"], style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/*
pubspen.yaml
name: travel_entertainment_app
description: Travel and entertainment management system

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=2.17.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  google_fonts: ^6.1.0
  flutter_card_swiper: ^6.0.0   # stable version

  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
 */