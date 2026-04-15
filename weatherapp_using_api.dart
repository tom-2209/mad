import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  TextEditingController cityController = TextEditingController();

  String city = "Your Location";
  String temp = "--";
  String weather = "";
  String icon = "⏳";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocationWeather();
  }

  // 📍 Current location weather
  Future<void> getLocationWeather() async {
    Position pos = await _determinePosition();
    getWeather("${pos.latitude},${pos.longitude}");
  }

  // 🔍 Search city weather
  Future<void> getWeather(String query) async {
    setState(() => isLoading = true);

    String url = "https://wttr.in/$query?format=j1";

    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);

    setState(() {
      temp = data["current_condition"][0]["temp_C"];
      weather = data["current_condition"][0]["weatherDesc"][0]["value"];
      icon = getIcon(weather);
      city = query.contains(",") ? "Your Location" : query;
      isLoading = false;
    });
  }

  String getIcon(String condition) {
    if (condition.contains("Cloud")) return "☁️";
    if (condition.contains("Rain")) return "🌧️";
    if (condition.contains("Sunny")) return "☀️";
    if (condition.contains("Clear")) return "🌤️";
    if (condition.contains("Thunder")) return "⛈️";
    return "🌈";
  }

  Color getBg() {
    if (weather.contains("Cloud")) return Colors.blueGrey;
    if (weather.contains("Rain")) return Colors.indigo;
    if (weather.contains("Sunny")) return Colors.orange;
    return Colors.blue;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location disabled");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBg(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),

            /// 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: cityController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter city...",
                  hintStyle: TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (cityController.text.isNotEmpty) {
                        getWeather(cityController.text);
                      }
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),

            /// WEATHER DISPLAY
            Expanded(
              child: Center(
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(icon, style: TextStyle(fontSize: 80)),
                    Text(
                      "$temp°C",
                      style: GoogleFonts.poppins(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      weather,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 📍 BUTTON TO RESET TO CURRENT LOCATION
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: getLocationWeather,
                child: Text("Use Current Location"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
pubspec.yaml
name: weatherapp_using_api
description: A simple weather app without API key

publish_to: 'none'

environment:
  sdk: '^3.11.0'

dependencies:
  flutter:
    sdk: flutter

  http: ^1.2.0
  geolocator: ^11.0.0
  google_fonts: ^6.1.0

flutter:
  uses-material-design: true
 */