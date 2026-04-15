import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FrontPage(),
    );
  }
}

//// ================= FRONT PAGE =================

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  Widget navButton(BuildContext context, String text, Color color, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel & Entertainment"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            navButton(context, "Movies", Colors.orange, const MoviesScreen()),
            navButton(context, "Travel Cost", Colors.green, const TravelScreen()),
            navButton(context, "Explore Places", Colors.teal, const ExploreScreen()),
          ],
        ),
      ),
    );
  }
}

//// ================= MOVIES =================

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  final List<Map<String, dynamic>> movies = const [
    {"title": "Leo", "genre": "Action", "rating": 4},
    {"title": "Jailer", "genre": "Drama", "rating": 5},
    {"title": "Vikram", "genre": "Thriller", "rating": 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movies")),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          var movie = movies[index];
          return Card(
            margin: const EdgeInsets.all(10),
            color: Colors.orange.shade100,
            child: ListTile(
              title: Text(movie['title']),
              subtitle: Text("Genre: ${movie['genre']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < movie['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.red,
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

//// ================= TRAVEL =================

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  String result = "";

  void calculateCost() {
    int distance =
        (fromController.text.length + toController.text.length) * 12;

    int cost = distance * 6;

    setState(() {
      result = "Distance: $distance km\nCost: ₹$cost";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel Cost")),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.blue],
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: fromController,
              decoration: const InputDecoration(
                  filled: true, fillColor: Colors.white, labelText: "From"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: toController,
              decoration: const InputDecoration(
                  filled: true, fillColor: Colors.white, labelText: "To"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateCost,
              child: const Text("Calculate"),
            ),
            const SizedBox(height: 20),
            Text(result,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

//// ================= EXPLORE =================

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, String>> places = [
    {"name": "Ooty", "desc": "Hill station", "famous": "Tea gardens"},
    {"name": "Goa", "desc": "Beach", "famous": "Night life"},
    {"name": "Manali", "desc": "Snow", "famous": "Adventure"},
    {"name": "Kodaikanal", "desc": "Cool hills", "famous": "Lake"},
    {"name": "Mysore", "desc": "Royal city", "famous": "Palace"},
    {"name": "Kerala", "desc": "Backwaters", "famous": "Houseboats"},
    {"name": "Jaipur", "desc": "Pink city", "famous": "Forts"},
  ];

  int currentIndex = 0;

  void nextPlace() {
    setState(() {
      currentIndex = (currentIndex + 1) % places.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    var place = places[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
          ),
        ),
        child: Center(
          child: GestureDetector(
            onHorizontalDragEnd: (_) => nextPlace(),
            child: Card(
              elevation: 15,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(place['name']!,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(place['desc']!,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Famous for: ${place['famous']}"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
name: untitled3
description: Travel & Entertainment App

publish_to: 'none'

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
  uses-material-design: true
 */