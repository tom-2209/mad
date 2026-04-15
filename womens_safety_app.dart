import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GuardianSafeApp());
}

class GuardianSafeApp extends StatelessWidget {
  const GuardianSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Safe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink, primary: Colors.pink.shade700),
        useMaterial3: true,
      ),
      home: const SafetyDashboard(),
    );
  }
}

class SafetyDashboard extends StatefulWidget {
  const SafetyDashboard({super.key});

  @override
  State<SafetyDashboard> createState() => _SafetyDashboardState();
}

class _SafetyDashboardState extends State<SafetyDashboard> {
  // Logic Variables
  bool _isTestMode = true;
  int _tapCount = 0;
  Timer? _tapTimer;
  StreamSubscription? _accelerometerSub;
  String _currentAddress = "Checking GPS...";

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
    _updateLocationStatus();
  }

  // FEATURE 1: SHAKE GESTURE
  void _startShakeDetection() {
    _accelerometerSub = accelerometerEventStream().listen((event) {
      // Threshold: 30 means a very sharp movement
      if (event.x.abs() > 30 || event.y.abs() > 30) {
        _handleSOS("SHAKE DETECTED");
      }
    });
  }

  // FEATURE 2: GPS TRACKING
  Future<void> _updateLocationStatus() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentAddress = "Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      setState(() => _currentAddress = "GPS Permission Required");
    }
  }

  // FEATURE 3: THE SOS ENGINE (SIMULATION vs LIVE)
  void _handleSOS(String triggerSource) async {
    HapticFeedback.vibrate(); // Physical feedback

    if (_isTestMode) {
      _showSimulationResult(triggerSource);
    } else {
      // LIVE MODE: Actually prepare the data
      Position pos = await Geolocator.getCurrentPosition();
      String mapLink = "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}";

      String message = "🚨 EMERGENCY SOS 🚨\nTrigger: $triggerSource\nLocation: $mapLink";
      Share.share(message);
    }
  }

  void _showSimulationResult(String source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.biotech, size: 40, color: Colors.blue),
        title: const Text("SOS SIMULATION"),
        content: Text("Trigger Successful: $source\n\nIn Live Mode, this would send your GPS coordinates to emergency contacts."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss"))
        ],
      ),
    );
  }

  // FEATURE 4: NEARBY HELP (POLICE/HOSPITAL)
  Future<void> _launchMaps(String query) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/$query+near+me");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch maps');
    }
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guardian Safe", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            children: [
              const Text("TEST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Switch(
                value: _isTestMode,
                onChanged: (val) => setState(() => _isTestMode = val),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Location Info
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.pink),
                    const SizedBox(width: 15),
                    Expanded(child: Text(_currentAddress, style: const TextStyle(fontWeight: FontWeight.w500))),
                    IconButton(onPressed: _updateLocationStatus, icon: const Icon(Icons.refresh))
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // MAIN SOS BUTTON
              GestureDetector(
                onTap: () {
                  _tapCount++;
                  if (_tapCount == 1) {
                    _tapTimer = Timer(const Duration(milliseconds: 600), () => _tapCount = 0);
                  } else if (_tapCount == 3) {
                    _handleSOS("TRIPLE TAP");
                    _tapCount = 0;
                  }
                },
                onLongPress: () => _handleSOS("SILENT LONG PRESS"),
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: (_isTestMode ? Colors.blue : Colors.red).withOpacity(0.3), blurRadius: 30, spreadRadius: 10)
                    ],
                    gradient: LinearGradient(
                      colors: _isTestMode ? [Colors.blue, Colors.blue.shade900] : [Colors.red, Colors.red.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emergency, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text("SOS", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text("SHAKE OR TRIPLE-TAP TO TRIGGER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 60),

              // NEARBY HELP SECTION
              const Align(alignment: Alignment.centerLeft, child: Text("FIND NEARBY ASSISTANCE", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _helpButton("Police", Icons.local_police, Colors.blue, "Police Station"),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _helpButton("Hospital", Icons.local_hospital, Colors.green, "Hospital"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpButton(String label, IconData icon, Color color, String query) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _launchMaps(query),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}










//name: guardian_safe_app
// description: "A comprehensive women's safety application with gesture-based SOS alerts."
//
// # Prevents accidental publishing to pub.dev
// publish_to: 'none'
//
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//
//   # 1. For Shake Gesture (Accelerometer)
//   sensors_plus: ^6.1.1
//
//   # 2. For GPS Location Tracking
//   geolocator: ^13.0.1
//
//   # 3. For Opening Maps (Nearby Police/Hospitals) and Phone Dialer
//   url_launcher: ^6.3.0
//
//   # 4. For Sharing SOS via SMS/WhatsApp
//   share_plus: ^10.1.2
//
//   # 5. For Push Notifications & Status Updates
//   flutter_local_notifications: ^17.2.2
//
//   # 6. For modern UI Icons and Fonts
//   cupertino_icons: ^1.0.8
//
// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^5.0.0
//
// flutter:
//   # Required for the emergency, police, and hospital icons
//   uses-material-design: true
//
//   # Add assets here if you want to include a custom SOS sound or logo
//   # assets:
//   #   - assets/images/logo.png
